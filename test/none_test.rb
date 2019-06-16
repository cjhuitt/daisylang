require "test_helper"
require "runtime/runtime"

class DaisyNoneTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("None", nil)
  end

  def test_constant_for_only_value
    assert_not_nil Constants.key?("none")
  end

  def test_logical_operations_exist
    assert_not_nil Constants["None"].lookup("?")
  end

  def test_stringifiable
    assert_true Constants["None"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["None"].lookup("toString")
  end

  def test_verifiable
    assert_true Constants["None"].has_contract(Constants["Verifiable"].ruby_value)
    assert_not_nil Constants["None"].lookup("?")
  end

end

