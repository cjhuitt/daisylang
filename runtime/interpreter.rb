root = File.expand_path("../../", __FILE__)
$:.unshift(root)
$:.unshift(root + "/runtime")

require 'parser'
require 'runtime'

class Interpreter
  def initialize(debug=false)
    @parser = Parser.new
    @context = RootContext
    @context.interpreter = self
    @debug = debug
  end

  def push_context(new_self)
    @context = Context.new(@context, new_self)
  end

  def pop_context()
    @context = @context.previous_context
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

  private
    def visit_Nodes(node)
      debug_print("Visiting Nodes")
      return_val = nil
      node.nodes.each do |node|
        return_val = node.accept(self)
        if @context.should_return
          return return_val || Constants["none"]
        end
      end
      return_val || Constants["none"]
    end

    def visit_SendMessageNode(node)
      receiver = node.receiver.nil? ? @context.current_self : node.receiver.accept(self)
      evaluated_args = node.arguments.map { |arg| arg.accept(self) }
      debug_print("Dispatching #{node.message} on #{receiver}")
      debug_print("Arguments: #{evaluated_args}")
      receiver.dispatch(@context, node.message, evaluated_args)
    end

    def visit_ArgumentNode(node)
      debug_print("Argument node: #{node.label} (#{node.value})")
      [node.label, node.value.accept(self)]
    end

    def visit_ParameterNode(node)
      value = node.value
      unless value.nil?
        if value.is_a? String
          value = @context.value_for(value)
        end
        if value.nil?
          node.type = node.value
          node.value = nil
        end
      end
      type = @context.definition_of(node.type)
      raise "Unknown parameter type" if type.nil? && value.nil?
      if type.nil?
        type = value.runtime_class unless value.nil?
      end
      DaisyParameter.new(node.label, type, value)
    end

    def visit_DefineMessageNode(node)
      debug_print("Define message #{node.name} with #{node.parameters}")
      returning = @context.definition_of(node.return_type)
      params = node.parameters.each { |param| param.accept(self) }
      method = DaisyMethod.new(node.name, returning, params, node.body)
      @context.current_class.runtime_methods[method.name] = method
    end

    def visit_IntegerNode(node)
      debug_print("IntegerNode #{node.value}")
      Constants["Integer"].new(node.value)
    end

    def visit_StringNode(node)
      debug_print("StringNode #{node.value}")
      Constants["String"].new(node.value)
    end

    def visit_IfNode(node)
      if node.condition.accept(self).ruby_value
        debug_print("If node: triggered")
        node.body.accept(self)
      else
        debug_print("If node: nogo")
        Constants["none"]
      end
    end

    def visit_ReturnNode(node)
      val = node.expression.accept(self)
      debug_print("Return node #{val}")
      @context.return_value = val
      @context.should_return = true
      val
    end

    def visit_GetVariableNode(node)
      debug_print("Getting value for #{node.id}")
      var = @context.value_for(node.id)
      raise "Referenced unknown variable #{node.id}" if var.nil?
      var
    end

    def visit_TrueNode(node)
      debug_print("True node")
      Constants["true"]
    end

    def visit_FalseNode(node)
      debug_print("False node")
      Constants["false"]
    end

    def visit_CommentNode(node)
      debug_print("Skipping comment")
    end

    def debug_print(message)
      puts message if @debug
    end
end

