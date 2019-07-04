root = File.expand_path("../../", __FILE__)
$:.unshift(root)
$:.unshift(root + "/runtime")

require 'parser'
require 'runtime'

class Interpreter
  attr_accessor :debug

  def initialize(initial_context=nil, debug=false)
    @parser = Parser.new
    @contexts = ContextManager.new(
      initial_context.nil? ? RootContext : initial_context)
    @contexts.context.interpreter = self
    @debug = debug
    @should_break = false
    @should_continue = false
  end

  def context()
    @contexts.context
  end

  def eval(code)
    nodes = @parser.parse(code, @debug)
    nodes.accept(self)
  end

  def visit(node)
    dispatch = "visit_#{node.class}".to_sym
    debug_print("visiting #{node.class}")
    retval = send(dispatch, node)
    debug_print("after visit #{node.class} got #{retval}")
    retval
  end

  def execute_method(receiver, arglist, return_type, method_body)
    context = @contexts.enter_method_scope(receiver)
    arglist.each do |name, value|
      context.symbols[name] = value
    end
    context.return_type = return_type

    method_body.accept(self)
    @contexts.leave_scope(context)
    context.return_value
  end

  private
    def visit_Nodes(node)
      debug_print("Visiting Nodes")
      return_val = nil
      node.nodes.each do |node|
        return_val = node.accept(self)
        if context.need_early_exit || @should_continue
          return return_val || Constants["none"]
        end
      end
      return_val || Constants["none"]
    end

    def visit_SendMessageNode(node)
      receiver = node.receiver.nil? ? context.current_self : node.receiver.accept(self)
      evaluated_args = node.arguments.map { |arg| arg.accept(self) }
      debug_print("Dispatching #{node.message} on #{receiver.runtime_class.name}")
      debug_print("Arguments: #{evaluated_args}")
      receiver.dispatch(context, node.message, evaluated_args)
    end

    def visit_ArgumentNode(node)
      debug_print("Argument node: #{node.label} (#{node.value})")
      [node.label, node.value.accept(self)]
    end

    def visit_ParameterNode(node)
      value = node.value.accept(self)
      if value.class == DaisyClass || value.class == DaisyContract
        type = value
        value = Constants["none"]
      else
        if value.ruby_value.class == DaisyEnumCategory
          type = value.ruby_value
          value = Constants["none"]
        else
          type = value.runtime_class
        end
      end
      DaisyParameter.new(node.label, type, value)
    end

    def visit_DefineMethodNode(node)
      debug_print("Define message #{node.name} with #{node.parameters}")
      returning = context.symbol(node.return_type, nil)
      params = node.parameters.map { |param| param.accept(self) }
      method = DaisyMethod.new(node.name, returning, params, node.body)
      context.assign_symbol(node.name, nil, Constants["Method"].new(method))
      context.add_method( method )
    end

    def visit_IntegerNode(node)
      debug_print("IntegerNode #{node.value}")
      Constants["Integer"].new(node.value)
    end

    def visit_StringNode(node)
      debug_print("StringNode #{node.value}")
      Constants["String"].new(node.value)
    end

    def execute_flow_control_body(body, looping=false)
      context = @contexts.enter_flow_control_block_scope(looping)
      returned = body.accept(self)
      @should_break = context.need_early_exit
      @contexts.leave_scope(context)
      returned
    end

    def visit_IfNode(node)
      condition_met = false
      node.condition_blocks.each do |block|
        if block.condition.accept(self).ruby_value
          debug_print("If node: triggered")
          execute_flow_control_body(block.body)
          condition_met = true
          break
        end
      end
      if !condition_met && !node.else_block.nil?
        debug_print("If node: else triggered")
        execute_flow_control_body(node.else_block.body)
      else
        debug_print("If node: nogo")
        Constants["none"]
      end
    end

    def visit_UnlessNode(node)
      if !node.condition_block.condition.accept(self).ruby_value
        debug_print("Unless node: triggered")
        execute_flow_control_body(node.condition_block.body)
      elsif !node.else_block.nil?
        debug_print("Unless node: else triggered")
        execute_flow_control_body(node.else_block.body)
      else
        debug_print("Unless node: nogo")
        Constants["none"]
      end
    end

    def visit_SwitchNode(node)
      condition_met = false
      value = node.value.accept(self)
      debug_print("Switch node on #{value.runtime_class.name}")
      node.condition_blocks.each do |block|
        if block.condition.accept(self) == value
          debug_print("Switch node: triggered")
          execute_flow_control_body(block.body)
          condition_met = true
          break
        end
      end
      if !condition_met && !node.else_block.nil?
        debug_print("Switch node: else triggered")
        execute_flow_control_body(node.else_block.body)
      else
        debug_print("Switch node: nogo")
        Constants["none"]
      end
    end

    def visit_WhileNode(node)
      @should_break = false
      while node.condition_block.condition.accept(self).ruby_value
        debug_print("While node: triggered")
        @should_continue = false
        execute_flow_control_body(node.condition_block.body, true)
        break if @should_break
      end
    end

    def visit_StandardForNode(node)
      @should_break = false
      debug_print("For array #{node.container}")
      container = node.container.accept(self)
      container.ruby_value.each do |item|
        if item.class == Array
          value = Constants["Array"].new(item)
        else
          value = item
        end
        context.assign_symbol(node.variable, nil, value)
        @should_continue = false
        retval = execute_flow_control_body(node.body, true)
        return retval if @should_break
      end
    end

    def visit_KeyValueForNode(node)
      @should_break = false
      debug_print("For hash #{node.container}")
      container = node.container.accept(self)
      container.ruby_value.each do |key, val|
        context.assign_symbol(node.key_symbol, nil, key)
        context.assign_symbol(node.value_symbol, nil, val)
        @should_continue = false
        retval = execute_flow_control_body(node.body, true)
        return retval if @should_break
      end
    end

    def visit_LoopNode(node)
      @should_break = false
      debug_print("Loop node")
      loop do
        @should_continue = false
        retval = execute_flow_control_body(node.body, true)
        return retval if @should_break
      end
    end

    def visit_BreakNode(node)
      debug_print("Break node")
      context.set_should_break
    end

    def visit_ContinueNode(node)
      debug_print("Continue node")
      @should_continue = true
    end

    def visit_ThrowNode(node)
      debug_print("Throw node")
      context.set_exception(node.exception.accept(self))
    end

    def visit_ReturnNode(node)
      val = node.expression.accept(self)
      debug_print("Return node #{val}")
      context.set_return(val)
      val
    end

    def visit_TryNode(node)
      debug_print("Try node")
      context = @contexts.enter_try_block_scope
      returned = node.body.accept(self)
      @should_break = context.need_early_exit
      local = context
      @contexts.leave_scope(context)
      if !local.exception_value.nil?
        node.handlers.each do |handler|
          if handler.type.nil? || context.symbol(handler.type, nil) == local.exception_value.runtime_class
            debug_print("Found Handler!")
            context = @contexts.enter_flow_control_block_scope
            if !handler.as.nil?
              context.assign_symbol(handler.as, nil, local.exception_value)
            end
            returned = handler.body.accept(self)
            @contexts.leave_scope(context)
          end
        end
      end
      returned
    end

    def visit_GetSymbolNode(node)
      debug_print("Getting value for #{node.id}")
      var = context.symbol(node.id, node.instance)
      raise "Referenced unknown symbol #{node.id}" if var.nil?
      var
    end

    def visit_SetSymbolNode(node)
      debug_print("Setting value for #{node.id}")
      val = node.value.accept(self)
      context.assign_symbol(node.id, node.instance, val.copy)
      val
    end

    def visit_TrueNode(node)
      debug_print("True node")
      Constants["true"]
    end

    def visit_FalseNode(node)
      debug_print("False node")
      Constants["false"]
    end

    def visit_NoneNode(node)
      debug_print("None node")
      Constants["none"]
    end

    def visit_PassNode(node)
      debug_print("Pass node")
      Constants["none"]
    end

    def visit_CommentNode(node)
      debug_print("Skipping comment")
      Constants["none"]
    end

    def debug_print(message)
      puts message if @debug
    end

    def visit_DefineClassNode(node)
      debug_print("Define class #{node.name}")
      daisy_class = DaisyClass.new(node.name, Constants["Object"])
      node.contracts.each do |contract_def|
        contract = context.symbol(contract_def.name, nil)
        raise DaisyError.new("Referenced unknown symbol #{contract_def.name}", contract_def.source_info) if contract.nil?
        daisy_class.add_contract(contract.ruby_value)
      end
      context.assign_symbol(node.name, nil, daisy_class)
      context = @contexts.enter_class_definition_scope(daisy_class)
      node.body.accept(self)
      @contexts.leave_scope(context)
    end

    def visit_DefineContractNode(node)
      debug_print("Define contract #{node.name}")
      contract = DaisyContract.new(node.name)
      context.assign_symbol(node.name, nil, contract)
      @contexts.enter_contract_definition_scope(contract)
      node.body.accept(self)
      @contexts.leave_scope(context)
    end

    def visit_EnumerateNode(node)
      debug_print("Enumerate #{node.name}")
      enum = DaisyEnumCategory.new(node.name)
      context.assign_symbol(node.name, nil, enum)
      node.symbols.each do |symbol|
        entry = enum.add(symbol.id)
        context.assign_symbol(symbol.id, nil, entry)
      end
    end

    def visit_ArrayNode(node)
      debug_print("ArrayNode #{node.members.size}")
      evaluated_members = node.members.map { |member| member.accept(self) }
      Constants["Array"].new(evaluated_members)
    end

    def visit_HashNode(node)
      debug_print("HashNode #{node.members.size}")
      hash = {}
      node.members.each do |member|
        hash[member.label.accept(self)] = member.value.accept(self)
      end
      Constants["Hash"].new(hash)
    end
end

