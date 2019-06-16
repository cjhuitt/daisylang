require "test_helper"
require "runtime/runtime"

class DaisyObjectTest < Test::Unit::TestCase
  def test_dispatch_works_with_existing_method
    daisy_class = DaisyClass.new("Test")
    ran = false
    context = Context.new(nil, nil, nil)
    interpreter = 123456
    context.interpreter = interpreter
    args = true
    daisy_object = DaisyObject.new(daisy_class)
    daisy_class.def :foo do |passed_interpreter, passed_receiver, passed_args|
      assert_equal interpreter, passed_interpreter
      assert_equal daisy_object, passed_receiver
      assert_equal args, passed_args
      ran = true
    end
    daisy_object.dispatch(context, "foo", args)
    assert_true ran
  end

  def test_dispatch_throws_with_no_method
    daisy_class = DaisyClass.new("Test")
    context = Context.new(nil, nil, nil)
    interpreter = 123456
    context.interpreter = interpreter
    daisy_object = DaisyObject.new(daisy_class)
    assert_raise do
      daisy_object.dispatch(context, "bar", args)
    end
  end

  def test_copy_makes_deep_copy
    foo = DaisyObject.new(Constants["Integer"], 1)
    foo.instance_data["baz"] = true
    bar = foo.copy
    foo.instance_data["baz"] = false
    assert_true bar.instance_data["baz"]
    assert_false foo.instance_data["baz"]
  end

  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Object", nil)
  end

  def test_print_function_exists
    assert_not_nil Constants["Object"].lookup("print")
  end

  def test_reflection_functions_exists
    assert_not_nil Constants["Object"].lookup("type")
    assert_not_nil Constants["Object"].lookup("isa?")
  end

  def test_equatable
    assert_true Constants["Object"].has_contract(Constants["Equatable"].ruby_value)
    assert_not_nil Constants["Object"].lookup("==")
    assert_not_nil Constants["Object"].lookup("!=")
  end

end
