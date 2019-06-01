root = File.expand_path("../../", __FILE__)
$:.unshift(root)
$:.unshift(root + "/runtime")

require 'parser'
require 'runtime'

class Interpreter
  def initialize(debug=false)
    @parser = Parser.new
    @context = RootContext
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
      receiver.dispatch(node.message, evaluated_args)
    end

    def visit_ArgumentNode(node)
      [node.label, node.value.accept(self)]
    end

    def visit_IntegerNode(node)
      Constants["Integer"].new(node.value)
    end

    def visit_StringNode(node)
      Constants["String"].new(node.value)
    end

    def debug_print(message)
      puts message if @debug
    end
end

