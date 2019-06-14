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
    context.assign_symbol("foo", "foo")
    assert_equal "foo", context.symbol("foo")
  end

  def test_finds_symbol_in_previous_context
    new_self = Constants["Object"].new
    prev_context = Context.new(nil, new_self)
    prev_context.assign_symbol("foo", "foo")
    context = Context.new(prev_context, new_self)
    assert_equal "foo", context.symbol("foo")
  end
end
