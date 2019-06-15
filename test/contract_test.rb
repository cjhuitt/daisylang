require "test_helper"
require "runtime/runtime"

class ContractTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Contract")
  end

  def test_predefined_contracts_in_root_context
    assert_not_nil RootContext.symbol("Stringifiable")
    assert_not_nil RootContext.symbol("Sortable")
  end

  def test_pretty_print_exists
    assert_true Constants["Contract"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Contract"].lookup("toString")
  end
end
