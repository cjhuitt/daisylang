require "test_helper"
require "runtime/runtime"

class DaisyContextTest < Test::Unit::TestCase
  def test_finds_interpreter_from_previous_class
    interpreter = "inter"
    new_self = Constants["Object"].new
    context = Context.new(RootContext, new_self)
    RootContext.interpreter = interpreter
    assert_equal interpreter, context.interpreter
  end

  def test_finds_symbol
    new_self = Constants["Object"].new
    context = Context.new(nil, new_self)
    context.assign_symbol("foo", nil, "foo")
    assert_equal "foo", context.symbol("foo", nil)
  end

  def test_finds_symbol_in_previous_context
    new_self = Constants["Object"].new
    prev_context = Context.new(nil, new_self)
    prev_context.assign_symbol("foo", nil, "foo")
    context = Context.new(prev_context, new_self)
    assert_equal "foo", context.symbol("foo", nil)
  end

  def test_add_method_puts_method_in_class
    daisy_class = DaisyClass.new("Foo", Constants["Object"])
    context = Context.new(nil, daisy_class, daisy_class)
    method = DaisyMethod.new("bar", Constants["None"], {}, NoneNode.new)
    context.add_method(method)
    assert_true daisy_class.runtime_methods.key?("bar")
  end

  def test_add_symbol_when_defining_class_adds_field_to_class
    new_self = Constants["Object"].new
    prev_context = Context.new(nil, new_self)
    daisy_class = DaisyClass.new("Foo", Constants["Object"])
    context = Context.new(prev_context, daisy_class, daisy_class)
    field = Constants["Integer"].new
    context.defining_class = daisy_class
    context.assign_symbol("foo", nil, field)
    assert_equal field, daisy_class.field("foo")
  end

  def test_retrieves_symbol_from_class_instance_if_available
    daisy_class = DaisyClass.new("Foo", Constants["Object"])
    new_self = Constants["Object"].new(daisy_class)
    context = Context.new(nil, new_self)
    field = Constants["Integer"].new(2)
    new_self.instance_data["foo"] = field
    assert_equal field, context.symbol("foo", nil)
  end
end
