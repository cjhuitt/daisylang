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
      node.nodes.each do |node|
        node.accept(self)
      end
    end

    def visit_SendMessageNode(node)
      receiver = node.receiver.nil? ? @context.current_self : node.receiver.accept(self)
      evaluated_args = node.arguments.map { |arg| arg.accept(self) }
      debug_print("Dispatching #{node.message} on #{receiver}")
      debug_print("Arguments: #{evaluated_args}")
      receiver.call(node.message, evaluated_args)
    end

    def visit_ArgumentNode(node)
      [node.label, node.value.accept(self)]
    end

    def visit_StringNode(node)
      node.value
    end

    def debug_print(message)
      puts message if @debug
    end
end

