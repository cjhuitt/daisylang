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

end
