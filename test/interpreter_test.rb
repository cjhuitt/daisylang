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

  def test_can_handle_comment
    assert_nothing_raised do
      @interpreter.eval("// This shouldn't do anything")
    end
  end

  def test_send_message_argument
    @interpreter.eval("a = 1 + 2")
    symbol = @interpreter.context.symbol("a")
    assert_equal Constants["Integer"], symbol.runtime_class
    assert_equal 3, symbol.ruby_value
  end

  def test_define_contract
    code = <<-CODE
Contract: Foo
    Function: None bar()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo")
    assert_not_nil symbol
    assert_equal Constants["Contract"], symbol.runtime_class
    contract = symbol.ruby_value
    assert_equal "Foo", contract.name
    assert_true contract.defines?("bar")
    method = contract.lookup("bar")
    assert_equal "bar", method.name
    assert_equal Constants["None"], method.return_type
    assert_equal [], method.params
  end

  def test_define_class_with_method
    code = <<-CODE
Class: Foo
    Function: None bar()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo")
    assert_not_nil symbol
    assert_equal Constants["Class"], symbol.runtime_class
    daisy_class = symbol.ruby_value
    assert_equal "Foo", daisy_class.name
    method = daisy_class.lookup("bar")
    assert_equal "bar", method.name
    assert_equal Constants["None"], method.return_type
    assert_equal [], method.params
  end

  def test_define_class_with_contracts
    code = <<-CODE
Class: Foo is Stringifiable, Sortable
    Function: None bar()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo")
    assert_not_nil symbol
    assert_equal Constants["Class"], symbol.runtime_class
    daisy_class = symbol.ruby_value
    assert_true daisy_class.has_contract(Constants["Stringifiable"].ruby_value)
    assert_true daisy_class.has_contract(Constants["Sortable"].ruby_value)
  end

  def test_define_class_with_fields
    code = <<-CODE
Class: Foo
    a = Integer.default()
    Function: String toString()
        return a.toString()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo")
    assert_not_nil symbol
    assert_equal Constants["Class"], symbol.runtime_class
    daisy_class = symbol.ruby_value
    field = daisy_class.field("a")
    assert_not_nil field
    assert_equal Constants["Integer"], field.runtime_class
  end

  def test_class_instance_can_use_fields
    code = <<-CODE
Class: Foo
    a = 2
    Function: String bar()
        return a.toString()

foo = Foo.default()
foo.bar()

CODE
    @interpreter.eval(code)
    daisy_class = @interpreter.context.symbol("Foo")
    assert_not_nil daisy_class
    symbol = @interpreter.context.symbol("foo")
    assert_not_nil symbol
    assert_equal daisy_class, symbol.runtime_class
    field = symbol.instance_data["a"]
    assert_not_nil field
    assert_equal Constants["Integer"], field.runtime_class
    assert_equal 2, field.ruby_value
  end

end