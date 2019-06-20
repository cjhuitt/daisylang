require "test_helper"
require "runtime/runtime"

class DaisyContextManagerTest < Test::Unit::TestCase
  def setup
    @test_self = Constants["Object"].new
    @test_context = Context.new(RootContext, @test_self)
    @manager = ContextManager.new(@test_context)
  end

  def cleanup
  end

  def test_symbol_defined_in_function_not_available_after_scope_is_left
    method_context = @manager.enter_method_context(@test_self)
    method_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_context(method_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

end
