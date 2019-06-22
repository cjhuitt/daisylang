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
      value = node.value
      unless value.nil?
        if value.is_a? String
          value = context.symbol(value, nil)
        else
          value = value.accept(self)
        end
      end
      type = context.symbol(node.type, nil)
      raise "Unknown parameter type" if type.nil? && value.nil?
      if type.nil?
        type = value.runtime_class unless value.nil?
      end
      DaisyParameter.new(node.label, type, value)
    end

    def visit_DefineMessageNode(node)
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

    def visit_WhileNode(node)
      @should_break = false
      while node.condition_block.condition.accept(self).ruby_value
        debug_print("While node: triggered")
        @should_continue = false
        execute_flow_control_body(node.condition_block.body, true)
        break if @should_break
      end
    end

    def visit_ForNode(node)
      @should_break = false
      debug_print("For node on #{node.container}")
      container = node.container.accept(self)
      container.ruby_value.each do |item|
        context.assign_symbol(node.variable, nil, item)
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

    def visit_ReturnNode(node)
      val = node.expression.accept(self)
      debug_print("Return node #{val}")
      context.set_return(val)
      val
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

    def visit_CommentNode(node)
      debug_print("Skipping comment")
    end

    def debug_print(message)
      puts message if @debug
    end

    def visit_DefineClassNode(node)
      debug_print("Define class #{node.name}")
      daisy_class = DaisyClass.new(node.name, Constants["Object"])
      node.contracts.each do |contract_name|
        contract = context.symbol(contract_name, nil)
        raise "Referenced unknown symbol #{contract_name}" if contract.nil?
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

    def visit_ArrayNode(node)
      debug_print("ArrayNode #{node.members.size}")
      evaluated_members = node.members.map { |member| member.accept(self) }
      Constants["Array"].new(evaluated_members)
    end
end

