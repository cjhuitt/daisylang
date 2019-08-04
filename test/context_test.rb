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
    assert_not_nil daisy_class.lookup("bar")
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

  def test_does_not_need_early_exit_if_no_method_context
    new_self = Constants["Object"].new
    context = Context.new(nil, new_self)
    context.set_return(new_self)
    assert_false context.need_early_exit
  end

  def test_does_not_need_early_exit_if_no_return_value_set
    new_self = Constants["Object"].new
    method_context = Context.new(nil, new_self)
    flow_context = Context.new(nil, new_self)
    flow_context.current_method_context = method_context
    assert_false flow_context.need_early_exit
  end

  def test_needs_early_exit_if_return_value_set_on_context_with_current_method
    new_self = Constants["Object"].new
    method_context = Context.new(nil, new_self)
    flow_context = Context.new(nil, new_self)
    flow_context.current_method_context = method_context
    flow_context.set_return(new_self)
    assert_true flow_context.need_early_exit
  end

  def test_does_not_need_early_exit_if_no_loop_context
    new_self = Constants["Object"].new
    flow_context = Context.new(nil, new_self)
    flow_context.set_should_break
    assert_false flow_context.need_early_exit
  end

  def test_does_not_need_early_exit_if_should_break_not_set
    new_self = Constants["Object"].new
    loop_context = Context.new(nil, new_self)
    flow_context = Context.new(nil, new_self)
    flow_context.current_loop_context = loop_context
    assert_false flow_context.need_early_exit
  end

  def test_needs_early_exit_if_loop_context_and_should_break_set
    new_self = Constants["Object"].new
    loop_context = Context.new(nil, new_self)
    flow_context = Context.new(nil, new_self)
    flow_context.current_loop_context = loop_context
    flow_context.set_should_break
    assert_true flow_context.need_early_exit
  end
end
