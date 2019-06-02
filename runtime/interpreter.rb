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
    retval = send(dispatch, node)
    debug_print("visit #{node.class} #{retval}")
    retval
  end

  private
    def visit_Nodes(node)
      debug_print("Visiting Nodes")
      return_val = nil
      node.nodes.each do |node|
        return_val = node.accept(self)
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
      debug_print("Argument node: #{node.label}")
      [node.label, node.value.accept(self)]
    end

    def visit_ParameterNode(node)
      puts "Unimplemented: ParameterNode"
      Constants["none"]
    end

    def visit_DefineMessageNode(node)
      debug_print("Define message #{node.name} with #{node.parameters}")
      returning = @context.definition_of(node.return_type)
      params = {}
      node.parameters.each { |param| params[param.label] = param.accept(self) }
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
      puts "Need to implement if"
      if node.condition.accept(self).ruby_value
        node.body.accept(self)
      else
        Constants["none"]
      end
    end

    def visit_ReturnNode(node)
      node.expression.accept(self)
    end

    def visit_GetVariableNode(node)
      debug_print("Getting value for #{node.id}")
      var = @context.value_for(node.id)
      raise "Referenced unknown variable #{node.id}" if var.nil?
      var
    end

    def debug_print(message)
      puts message if @debug
    end
end

