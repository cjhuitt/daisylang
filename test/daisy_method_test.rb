require "test_helper"
require "runtime/runtime"
require "runtime/interpreter"

class BodyMock
  attr_reader :interpreter, :context, :current_self, :called
  def initialize
    @interpreter = nil
    @context = nil
    @current_self = nil
    @called = false
  end

  def accept(interpreter)
    @interpreter = interpreter
    @context = interpreter.context
    @current_self = interpreter.context.current_self
    @called = true
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
end
