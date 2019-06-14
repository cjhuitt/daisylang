require "test_helper"
require "runtime/runtime"
require "runtime/interpreter"

class BodyMock
  attr_reader :interpreter, :context, :called
  def initialize
    @interpreter = nil
    @context = nil
    @called = false
  end

  def accept(interpreter)
    @interpreter = interpreter
    @context = interpreter.context
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

end
