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
    method_context = @manager.enter_method_scope(@test_self)
    method_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_scope(method_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

  def test_symbol_defined_in_root_scope_available_in_method_scope
    method_context = @manager.enter_method_scope(@test_self)
    assert_equal Constants["None"], @manager.context.symbol("None", nil)
    @manager.leave_scope(method_context)
  end

  def test_symbol_defined_in_root_scope_available_in_class_definition_scope
    daisy_class = DaisyClass.new("Foo", Constants["Object"])
    class_context = @manager.enter_class_definition_scope(daisy_class)
    assert_equal Constants["None"], @manager.context.symbol("None", nil)
    @manager.leave_scope(class_context)
  end

  def test_symbol_defined_in_root_scope_available_in_contract_definition_scope
    contract = DaisyContract.new("Foo")
    contract_context = @manager.enter_contract_definition_scope(contract)
    assert_equal Constants["None"], @manager.context.symbol("None", nil)
    @manager.leave_scope(contract_context)
  end

end
