root = File.expand_path("../../", __FILE__)
$:.unshift(root)
$:.unshift(root + "/runtime")

require 'parser'
require 'runtime'

class Interpreter
  def initialize
    @parser = Parser.new
  end

  def eval(code)
    nodes = @parser.parse(code)
    nodes.accept(self)
  end

  def visit(node)
    print "Visiting #{node}"
  end
end

