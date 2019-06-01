root = File.expand_path("../../", __FILE__)
$:.unshift(root)
$:.unshift(root + "/runtime")

require 'parser'
require 'runtime'

class Interpreter
  def initialize
    @parser = Parser.new
    @context = RootContext
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
      puts "Visiting Nodes"
      node.nodes.each do |node|
        node.accept(self)
      end
    end

    def visit_SendMessageNode(node)
      receiver = node.receiver.nil? ? @context.current_self : node.receiver.accept(self)
      evaluated_args = node.arguments.map { |arg| arg.accept(self) }
      puts "Visiting SendMessageNode"
    end

    def visit_ArgumentNode(node)
      puts "Visiting ArgumentNode"
    end
end

