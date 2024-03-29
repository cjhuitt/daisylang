require "test_helper"
require "runtime/runtime"
require "runtime/interpreter"

class BodyMock
  attr_reader :interpreter, :context, :current_self, :called
  def initialize(return_val=nil)
    @interpreter = nil
    @context = nil
    @current_self = nil
    @called = false
    @return_val = return_val
  end

  def accept(interpreter)
    @interpreter = interpreter
    @context = interpreter.context
    @current_self = interpreter.context.current_self
    @called = true
    @context.return_value = @return_val
  end
end

class DaisyMethodTest < Test::Unit::TestCase
  def test_basic_call
    body = BodyMock.new
    method = DaisyMethod.new("foo", Constants["None"], {}, body)
    interp = Interpreter.new
    method.call(interp, method, {})
    assert_true body.called
  end

  def test_adds_self_to_context
    body = BodyMock.new
    method = DaisyMethod.new("foo", Constants["None"], {}, body)
    interp = Interpreter.new
    method.call(interp, method, {})
    assert_equal method, body.current_self
  end

  def test_adds_params_to_context
    body = BodyMock.new
    a = Constants["true"]
    paramA = DaisyParameter.new("a", Constants["Boolean"], a)
    b = Constants["Integer"].new(1)
    paramB = DaisyParameter.new("b", Constants["Integer"], b)
    params = [paramA, paramB]
    method = DaisyMethod.new("foo", Constants["None"], params, body)
    interp = Interpreter.new
    method.call(interp, method, {})
    assert_equal a, body.context.symbol("a", nil)
    assert_equal b, body.context.symbol("b", nil)
  end

  def test_adds_arg_values_to_context
    body = BodyMock.new
    a = Constants["true"]
    paramA = DaisyParameter.new("a", Constants["Boolean"], a)
    b = Constants["Integer"].new(1)
    paramB = DaisyParameter.new("b", Constants["Integer"], b)
    params = [paramA, paramB]
    method = DaisyMethod.new("foo", Constants["None"], params, body)
    interp = Interpreter.new
    args = [[ "a", Constants["false"] ]]
    method.call(interp, method, args)
    assert_equal Constants["false"], body.context.symbol("a", nil)
    assert_equal b, body.context.symbol("b", nil)
  end

  def test_does_not_add_args_for_nonexistant_params_to_context
    body = BodyMock.new
    params = []
    method = DaisyMethod.new("foo", Constants["None"], params, body)
    interp = Interpreter.new
    args = { "a" => Constants["false"] }
    method.call(interp, method, args)
    assert_equal nil, body.context.symbol("a", nil)
  end

  def test_returns_value_from_body
    retval = Constants["String"].new("Tralalalala")
    body = BodyMock.new(retval)
    params = []
    method = DaisyMethod.new("foo", Constants["None"], params, body)
    interp = Interpreter.new
    assert_equal retval, method.call(interp, method, {})
  end

  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Method", nil)
  end

  def test_stringifiable
    assert_true Constants["Method"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Method"].lookup("toString")
  end

  def test_equatable
    assert_true Constants["Method"].has_contract(Constants["Equatable"].ruby_value)
    assert_not_nil Constants["Method"].lookup("==")
    assert_not_nil Constants["Method"].lookup("!=")
  end

end
