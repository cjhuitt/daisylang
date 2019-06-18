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
    symbol = @interpreter.context.symbol("asdf", nil)
    assert_equal Constants["true"], symbol
    assert_equal Constants["Boolean"], symbol.runtime_class
  end

  def test_can_handle_null_program
    assert_nothing_raised do
      @interpreter.eval("")
    end
  end

  def test_get_symbol
    RootContext.assign_symbol("foo", nil, Constants["false"])
    assert_nothing_raised do
      @interpreter.eval("foo")
    end
  end

  def test_define_method
    # TODO: This should not be defined on all objects?
    code = <<-CODE
Method: String Greeting()
    return "Hey"

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Greeting", nil)
    assert_equal Constants["Method"], symbol.runtime_class
    method = symbol.ruby_value
    assert_equal "Greeting", method.name
    assert_equal Constants["String"], method.return_type
    assert_equal [], method.params
  end

  def test_send_message
    code = <<-CODE
Method: String Greeting()
    return "Hey"

retval = Greeting()
CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("retval", nil)
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
    symbol = @interpreter.context.symbol("a", nil)
    assert_equal Constants["false"], symbol
  end

  def test_unless_expression
    code = <<-CODE
a = true
unless false
    a = false

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("a", nil)
    assert_equal Constants["false"], symbol
  end

  def test_if_else_expression
    code = <<-CODE
a = 1
if false
    a = 2
else
    a = 3

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("a", nil)
    assert_equal 3, symbol.ruby_value
  end

  def test_unless_else_expression
    code = <<-CODE
a = 1
unless true
    a = 2
else
    a = 3

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("a", nil)
    assert_equal 3, symbol.ruby_value
  end

  def test_can_handle_comment
    assert_nothing_raised do
      @interpreter.eval("// This shouldn't do anything")
    end
  end

  def test_send_message_argument
    @interpreter.eval("a = 1 + 2")
    symbol = @interpreter.context.symbol("a", nil)
    assert_equal Constants["Integer"], symbol.runtime_class
    assert_equal 3, symbol.ruby_value
  end

  def test_define_contract
    code = <<-CODE
Contract: Foo
    Method: None bar()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo", nil)
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
    Method: None bar()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo", nil)
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
Class: Foo is Stringifiable, Comperable
    Method: None bar()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo", nil)
    assert_not_nil symbol
    assert_equal Constants["Class"], symbol.runtime_class
    daisy_class = symbol.ruby_value
    assert_true daisy_class.has_contract(Constants["Stringifiable"].ruby_value)
    assert_true daisy_class.has_contract(Constants["Comperable"].ruby_value)
  end

  def test_define_class_with_fields
    code = <<-CODE
Class: Foo
    a = Integer.create()
    Method: String toString()
        return a.toString()

CODE
    @interpreter.eval(code)
    symbol = @interpreter.context.symbol("Foo", nil)
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
    Method: String bar()
        return a.toString()

foo = Foo.create()
foo.bar()

CODE
    @interpreter.eval(code)
    daisy_class = @interpreter.context.symbol("Foo", nil)
    assert_not_nil daisy_class
    symbol = @interpreter.context.symbol("foo", nil)
    assert_not_nil symbol
    assert_equal daisy_class, symbol.runtime_class
    field = symbol.instance_data["a"]
    assert_not_nil field
    assert_equal Constants["Integer"], field.runtime_class
    assert_equal 2, field.ruby_value
  end

  def test_instance_can_change_fields
    code = <<-CODE
Class: Foo
    a = 2
    Method: None change()
        a = 5

foo = Foo.create()
foo.change()

CODE
    @interpreter.eval(code)
    foo = @interpreter.context.symbol("foo", nil)
    assert_not_nil foo
    a = foo.instance_data["a"]
    assert_not_nil a
    assert_equal Constants["Integer"], a.runtime_class
    assert_equal 5, a.ruby_value
  end

  def test_can_create_class_instance_and_override_defaults
    code = <<-CODE
Class: Foo
    a = 2
    Method: None init()
        a = 5

foo = Foo.create()

CODE
    @interpreter.eval(code)
    foo = @interpreter.context.symbol("foo", nil)
    assert_not_nil foo
    a = foo.instance_data["a"]
    assert_not_nil a
    assert_equal Constants["Integer"], a.runtime_class
    assert_equal 5, a.ruby_value
  end

  def test_can_assign_to_instance_member
    code = <<-CODE
Class: Foo
    a = 2
    Method: None change( other: Foo )
        other.a = 5

foo = Foo.create()
bar = Foo.create()
foo.change( bar )

CODE
    @interpreter.eval(code)

    foo = @interpreter.context.symbol("foo", nil)
    assert_not_nil foo
    foo_a = foo.instance_data["a"]
    assert_not_nil foo_a
    assert_equal Constants["Integer"], foo_a.runtime_class
    assert_equal 2, foo_a.ruby_value

    bar = @interpreter.context.symbol("bar", nil)
    assert_not_nil bar
    bar_a = bar.instance_data["a"]
    assert_not_nil bar_a
    assert_equal Constants["Integer"], bar_a.runtime_class
    assert_equal 5, bar_a.ruby_value
  end

  def test_can_not_assign_to_symbols_that_are_not_already_defined
    code = <<-CODE
Class: Foo
    a = 2
    Method: None change( other: Foo )
        other.b = 5

foo = Foo.create()
bar = Foo.create()
foo.change( bar )

CODE
    assert_raise do
      @interpreter.eval(code)
    end
  end

  def test_can_read_class_instance_fields
    code = <<-CODE
Class: Foo
    a = 2
    Method: None init( val: Integer )
        a = val
    
    Method: None assign!( other: Foo )
        a = other.a

foo = Foo.create( 5 )
bar = Foo.create( 7 )
foo.assign!( bar )

CODE
    @interpreter.eval(code)
    foo = @interpreter.context.symbol("foo", nil)
    assert_not_nil foo
    foo_a = foo.instance_data["a"]
    assert_not_nil foo_a
    assert_equal Constants["Integer"], foo_a.runtime_class

    bar = @interpreter.context.symbol("bar", nil)
    assert_not_nil bar
    bar_a = bar.instance_data["a"]
    assert_not_nil bar_a
    assert_equal Constants["Integer"], bar_a.runtime_class

    assert_equal bar_a.ruby_value, foo_a.ruby_value
    assert_equal 7, foo_a.ruby_value
  end

  def test_assign_copies
    code = <<-CODE
Class: Foo
    a = 2
    Method: None init( val: Integer )
        a = val
    
    Method: None assign!( val: Integer )
        a = val

foo = Foo.create( 5 )
bar = foo
foo.assign!( 2 )

CODE
    @interpreter.eval(code)
    foo = @interpreter.context.symbol("foo", nil)
    assert_not_nil foo
    foo_a = foo.instance_data["a"]
    assert_not_nil foo_a
    assert_equal Constants["Integer"], foo_a.runtime_class
    assert_equal 2, foo_a.ruby_value

    bar = @interpreter.context.symbol("bar", nil)
    assert_not_nil bar
    bar_a = bar.instance_data["a"]
    assert_not_nil bar_a
    assert_equal Constants["Integer"], bar_a.runtime_class
    assert_equal 5, bar_a.ruby_value
  end

  def test_for_construct
    code = <<-CODE
sum = 0
for a in [1, 2, 3]
    sum = sum + a

CODE
    @interpreter.eval(code)
    sum = @interpreter.context.symbol("sum", nil)
    assert_equal Constants["Integer"], sum.runtime_class
    assert_equal 6, sum.ruby_value
  end

  def test_getting_methods
    code = <<-CODE
methods = Boolean.methods()
CODE
    @interpreter.eval(code)
    methods = @interpreter.context.symbol("methods", nil)
    assert_equal Constants["Array"], methods.runtime_class
    assert_equal Constants["String"], methods.ruby_value.first.runtime_class
    # TODO This contains some methods that it should not.
    #      The list permutations below allow for a robust test while other 
    #      methods are added
    # TODO This should return method objects, not just names
    #      Once I figure out how to expose the built-ins as method objects
    assert_true methods.ruby_value.size >= 7
    list = methods.ruby_value.map do |method|
      method.ruby_value
    end
    assert_true list.include? "=="
    assert_true list.include? "!="
    assert_true list.include? "!"
    assert_true list.include? "?"
    assert_true list.include? "&&"
    assert_true list.include? "||"
    assert_true list.include? "toString"
  end

  def test_getting_contracts
    code = <<-CODE
contracts = true.contracts()
CODE
    @interpreter.eval(code)
    contracts = @interpreter.context.symbol("contracts", nil)
    assert_equal Constants["Array"], contracts.runtime_class
    assert_equal 3, contracts.ruby_value.size
    assert_true contracts.ruby_value.include? Constants["Stringifiable"]
    assert_true contracts.ruby_value.include? Constants["Equatable"]
    assert_true contracts.ruby_value.include? Constants["Verifiable"]
  end

  def test_while_construct
    code = <<-CODE
sum = 0
count = 0
while count <= 3
    sum = sum + count
    count = count + 1

CODE
    @interpreter.eval(code)
    sum = @interpreter.context.symbol("sum", nil)
    assert_equal Constants["Integer"], sum.runtime_class
    assert_equal 6, sum.ruby_value
  end

  def test_if_else_if_expression
    code = <<-CODE
result = 0
a = false
b = true
if a?
    result = 1
else if b?
    result = 2
else
    result = 3

CODE
    @interpreter.eval(code)
    result = @interpreter.context.symbol("result", nil)
    assert_equal Constants["Integer"], result.runtime_class
    assert_equal 2, result.ruby_value
  end

end
