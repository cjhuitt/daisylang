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

  def eval(code)
    nodes = @parser.parse(code)
    nodes.accept(self)
  end

  def visit(node)
    dispatch = "visit_#{node.class}".to_sym
    send(dispatch, node)
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
      [node.label, node.value.accept(self)]
    end

    def visit_DefineMessageNode(node)
      returning = @context.defined_types[node.return_type]
      method = DaisyMethod.new(node.name, returning, node.parameters, node.body)
      @context.current_class.runtime_methods[method.name] = method
    end

    def visit_IntegerNode(node)
      Constants["Integer"].new(node.value)
    end

    def visit_StringNode(node)
      Constants["String"].new(node.value)
    end

    def visit_IfNode(node)
      puts "Need to implement if"
      return Constants["none"]
      if node.condition.accept(self).ruby_value
        node.body.accept(self)
      end
    end

    def visit_ReturnNode(node)
      puts "Need to implement return"
    end

    def visit_GetVariableNode(node)
      puts "Need to implement getting a variable"
      Constants["none"]
    end

    def debug_print(message)
      puts message if @debug
    end
end

