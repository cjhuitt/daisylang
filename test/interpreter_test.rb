require "test_helper"
require "runtime/interpreter"

class TestNode
  attr_accessor :visited

  def initialize
    @visited = false
  end

  include Visitable
end

class InterpreterMock < Interpreter
  def visit_TestNode(node)
    node.visited = true
  end
end

class DaisyInterpreterTest < Test::Unit::TestCase
  def test_can_define_variable
    interpreter = Interpreter.new
    interpreter.eval("asdf = true")
    assert_equal Constants["true"], interpreter.context.symbol("asdf")
  end

end
