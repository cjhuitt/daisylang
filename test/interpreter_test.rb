require "test_helper"
require "runtime/interpreter"

class DaisyInterpreterTest < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
  end

  def test_can_define_variable
    @interpreter = Interpreter.new
    @interpreter.eval("asdf = true")
    symbol = @interpreter.context.symbol("asdf")
    assert_equal Constants["true"], symbol
    assert_equal Constants["Boolean"], symbol.runtime_class
  end
end
