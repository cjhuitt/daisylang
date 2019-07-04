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

  # Test symbols that should be available in subsequence scopes

  def test_symbol_defined_in_root_scope_available_in_file_scope
    file = Constants["Object"].new
    file_context = @manager.enter_file_scope(file)
    assert_equal Constants["None"], @manager.context.symbol("None", nil)
    @manager.leave_scope(file_context)
  end

  def test_symbol_defined_in_root_scope_available_in_method_scope
    method_context = @manager.enter_method_scope(@test_self)
    assert_equal Constants["None"], @manager.context.symbol("None", nil)
    @manager.leave_scope(method_context)
  end

  def test_symbol_defined_in_root_scope_available_in_flow_control_block_scope
    flow_context = @manager.enter_flow_control_block_scope()
    assert_equal Constants["None"], @manager.context.symbol("None", nil)
    @manager.leave_scope(flow_context)
  end

  def test_symbol_defined_in_root_scope_available_in_try_block_scope
    flow_context = @manager.enter_try_block_scope()
    assert_equal Constants["None"], @manager.context.symbol("None", nil)
    @manager.leave_scope(flow_context)
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

  def test_symbol_defined_in_file_scope_available_in_method_scope
    file = Constants["Object"].new
    file_context = @manager.enter_file_scope(file)
    file_context.assign_symbol("foo", nil, Constants["true"])
    method_context = @manager.enter_method_scope(@test_self)
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(method_context)
    @manager.leave_scope(file_context)
  end

  def test_symbol_defined_in_file_scope_available_in_flow_control_block_scope
    file = Constants["Object"].new
    file_context = @manager.enter_file_scope(file)
    file_context.assign_symbol("foo", nil, Constants["true"])
    flow_context = @manager.enter_flow_control_block_scope()
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(flow_context)
    @manager.leave_scope(file_context)
  end

  def test_symbol_defined_in_file_scope_available_in_try_block_scope
    file = Constants["Object"].new
    file_context = @manager.enter_file_scope(file)
    file_context.assign_symbol("foo", nil, Constants["true"])
    flow_context = @manager.enter_try_block_scope()
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(flow_context)
    @manager.leave_scope(file_context)
  end

  def test_symbol_defined_in_file_scope_available_in_class_definition_scope
    file = Constants["Object"].new
    file_context = @manager.enter_file_scope(file)
    file_context.assign_symbol("foo", nil, Constants["true"])
    daisy_class = DaisyClass.new("Foo", Constants["Object"])
    class_context = @manager.enter_class_definition_scope(daisy_class)
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(class_context)
    @manager.leave_scope(file_context)
  end

  def test_symbol_defined_in_file_scope_available_in_contract_definition_scope
    file = Constants["Object"].new
    file_context = @manager.enter_file_scope(file)
    file_context.assign_symbol("foo", nil, Constants["true"])
    contract = DaisyContract.new("Foo")
    contract_context = @manager.enter_contract_definition_scope(contract)
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(contract_context)
    @manager.leave_scope(file_context)
  end

  def test_symbol_defined_in_method_scope_available_in_flow_control_block_scope
    method_context = @manager.enter_method_scope(@test_self)
    method_context.assign_symbol("foo", nil, Constants["true"])
    flow_context = @manager.enter_flow_control_block_scope()
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(flow_context)
    @manager.leave_scope(method_context)
  end

  def test_symbol_defined_in_method_scope_available_in_try_block_scope
    method_context = @manager.enter_method_scope(@test_self)
    method_context.assign_symbol("foo", nil, Constants["true"])
    flow_context = @manager.enter_try_block_scope()
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(flow_context)
    @manager.leave_scope(method_context)
  end

  def test_symbol_defined_in_method_scope_available_in_class_definition_scope
    method_context = @manager.enter_method_scope(@test_self)
    method_context.assign_symbol("foo", nil, Constants["true"])
    daisy_class = DaisyClass.new("Foo", Constants["Object"])
    class_context = @manager.enter_class_definition_scope(daisy_class)
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(class_context)
    @manager.leave_scope(method_context)
  end

  def test_symbol_defined_in_method_scope_available_in_contract_definition_scope
    method_context = @manager.enter_method_scope(@test_self)
    method_context.assign_symbol("foo", nil, Constants["true"])
    contract = DaisyContract.new("Foo")
    contract_context = @manager.enter_contract_definition_scope(contract)
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(contract_context)
    @manager.leave_scope(method_context)
  end

  def test_symbol_defined_in_flow_control_block_scope_available_in_subsequent_flow_control_block_scope
    flow_context1 = @manager.enter_flow_control_block_scope()
    flow_context1.assign_symbol("foo", nil, Constants["true"])
    flow_context2 = @manager.enter_flow_control_block_scope()
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(flow_context2)
    @manager.leave_scope(flow_context1)
  end

  def test_symbol_defined_in_try_block_scope_available_in_subsequent_try_block_scope
    flow_context1 = @manager.enter_try_block_scope()
    flow_context1.assign_symbol("foo", nil, Constants["true"])
    flow_context2 = @manager.enter_try_block_scope()
    assert_equal Constants["true"], @manager.context.symbol("foo", nil)
    @manager.leave_scope(flow_context2)
    @manager.leave_scope(flow_context1)
  end

  # Test symbols after scopes are left:

  def test_symbol_defined_in_file_not_available_after_scope_is_left
    file = Constants["Object"].new
    file_context = @manager.enter_file_scope(file)
    file_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_scope(file_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

  def test_symbol_defined_in_method_not_available_after_scope_is_left
    method_context = @manager.enter_method_scope(@test_self)
    method_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_scope(method_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

  def test_symbol_defined_in_flow_control_block_not_available_after_scope_is_left
    flow_context = @manager.enter_flow_control_block_scope()
    flow_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_scope(flow_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

  def test_symbol_defined_in_try_block_not_available_after_scope_is_left
    flow_context = @manager.enter_try_block_scope()
    flow_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_scope(flow_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

  def test_symbol_defined_in_class_scope_not_available_after_scope_is_left
    daisy_class = DaisyClass.new("Foo", Constants["Object"])
    class_context = @manager.enter_class_definition_scope(daisy_class)
    class_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_scope(class_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

  def test_symbol_defined_in_contract_scope_not_available_after_scope_is_left
    contract = DaisyContract.new("Foo")
    contract_context = @manager.enter_contract_definition_scope(contract)
    contract_context.assign_symbol("foo", nil, Constants["true"])
    @manager.leave_scope(contract_context)
    assert_nil @manager.context.symbol("foo", nil)
  end

  # Test symbols that should *not* be available in subsequent scopes

  def test_symbol_defined_in_file_not_available_in_subsequent_file_scope
    file1 = Constants["Object"].new
    file2 = Constants["Object"].new
    file1_context = @manager.enter_file_scope(file1)
    file1_context.assign_symbol("foo", nil, Constants["true"])
    file2_context = @manager.enter_file_scope(file2)
    assert_nil @manager.context.symbol("foo", nil)
    @manager.leave_scope(file2_context)
    @manager.leave_scope(file1_context)
  end

  def test_symbol_defined_in_method_not_available_in_subsequent_method_scope
    method1_context = @manager.enter_method_scope(@test_self)
    method1_context.assign_symbol("foo", nil, Constants["true"])
    method2_context = @manager.enter_method_scope(@test_self)
    assert_nil @manager.context.symbol("foo", nil)
    @manager.leave_scope(method2_context)
    @manager.leave_scope(method1_context)
  end

 
  # Test return flags work through nested flow control scopes
  def test_return_value_set_in_flow_control_scope_propogates_to_method_scope
    method_context = @manager.enter_method_scope(@test_self)
    method_context.return_type = Constants["Boolean"]
    flow_context = @manager.enter_flow_control_block_scope()
    flow_context.set_return(Constants["true"])
    @manager.leave_scope(flow_context)
    assert_equal Constants["Boolean"], method_context.return_type
    assert_equal Constants["true"], method_context.return_value
    assert_true method_context.should_return
    @manager.leave_scope(method_context)
  end

  def test_return_value_set_in_try_scope_propogates_to_method_scope
    method_context = @manager.enter_method_scope(@test_self)
    method_context.return_type = Constants["Boolean"]
    flow_context = @manager.enter_try_block_scope()
    flow_context.set_return(Constants["true"])
    @manager.leave_scope(flow_context)
    assert_equal Constants["Boolean"], method_context.return_type
    assert_equal Constants["true"], method_context.return_value
    assert_true method_context.should_return
    @manager.leave_scope(method_context)
  end


  # Test exceptions work through nested flow control scopes
  def test_exceptions_propogage_through_nexted_scopes
    try_context = @manager.enter_try_block_scope
    method_context = @manager.enter_method_scope(@test_self)
    flow_context = @manager.enter_flow_control_block_scope()
    flow_context.set_exception(Constants["true"])
    assert_true flow_context.need_early_exit
    @manager.leave_scope(flow_context)
    assert_true method_context.need_early_exit
    @manager.leave_scope(method_context)
    assert_equal Constants["true"], try_context.exception_value
    @manager.leave_scope(try_context)
  end


  # Test early scope exit scenarios
  def test_early_exit_needed_in_contexts_with_method_return_value_set
    method_context = @manager.enter_method_scope(@test_self)
    method_context.return_type = Constants["Boolean"]
    flow_context = @manager.enter_flow_control_block_scope()
    flow_context.set_return(Constants["true"])
    assert_true flow_context.need_early_exit
    @manager.leave_scope(flow_context)
    assert_true method_context.need_early_exit
    @manager.leave_scope(method_context)
  end

  def test_early_exit_needed_in_loop_flow_contexts_with_break_set
    method_context = @manager.enter_method_scope(@test_self)
    method_context.return_type = Constants["Boolean"]
    flow_context = @manager.enter_flow_control_block_scope(true)
    flow_context.set_should_break
    assert_true flow_context.current_loop_context.should_break
    assert_true flow_context.need_early_exit
    @manager.leave_scope(flow_context)
    assert_false method_context.need_early_exit
    @manager.leave_scope(method_context)
  end

  def test_early_exit_needed_in_try_blocks_with_throw_set
    method_context = @manager.enter_method_scope(@test_self)
    flow_context = @manager.enter_try_block_scope
    flow_context.set_exception 1
    assert_true flow_context.need_early_exit
    @manager.leave_scope(flow_context)
    @manager.leave_scope(method_context)
  end

end
