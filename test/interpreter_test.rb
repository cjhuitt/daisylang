require "test_helper"
require "runtime/interpreter"

class DaisyInterpreterTest < Test::Unit::TestCase
  def setup
    @interpreter = Interpreter.new
    new_self = Constants["Object"].new
    @interpreter.push_context(new_self)
  end

  def cleanup
    @interpreter.pop_context
  end

  def test_can_define_variable
    @interpreter.eval("asdf = true")
    symbol = @interpreter.context.symbol("asdf")
    assert_equal Constants["true"], symbol
    assert_equal Constants["Boolean"], symbol.runtime_class
  end

  def test_can_handle_null_program
    assert_nothing_raised do
      @interpreter.eval("")
    end
  end

  def test_get_symbol
    RootContext.assign_symbol("foo", Constants["false"])
    assert_nothing_raised do
      @interpreter.eval("foo")
    end
  end

  def test_define_method
    code = <<-CODE
Function: String Greeting()
    return "Hey"

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Greeting")
    assert_equal Constants["Function"], symbol.runtime_class
    method = symbol.ruby_value
    assert_equal "Greeting", method.name
    assert_equal Constants["String"], method.return_type
    assert_equal [], method.params
  end

  def test_send_message
    code = <<-CODE
Function: String Greeting()
    return "Hey"

retval = Greeting()
CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("retval")
    assert_equal Constants["String"], symbol.runtime_class
    assert_equal "Hey", symbol.ruby_value
  end

  def test_if_expression
    code = <<-CODE
a = true
if true
    a = false

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("a")
    assert_equal Constants["false"], symbol
  end

  def test_unless_expression
    code = <<-CODE
a = true
unless false
    a = false

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("a")
    assert_equal Constants["false"], symbol
  end
end
