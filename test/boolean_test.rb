require "test_helper"
require "runtime/runtime"

class DaisyBooleanTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Boolean", nil)
  end

  def test_constants_for_only_values
    assert_not_nil Constants.key?("true")
    assert_not_nil Constants.key?("false")
  end

  def test_equality_operations_exists
    assert_not_nil Constants["Boolean"].lookup("==")
    assert_not_nil Constants["Boolean"].lookup("!=")
  end

  def test_logical_operations_exists
    assert_not_nil Constants["Boolean"].lookup("!")
    assert_not_nil Constants["Boolean"].lookup("?")
    assert_not_nil Constants["Boolean"].lookup("&&")
    assert_not_nil Constants["Boolean"].lookup("||")
  end

  def test_stringifiable
    assert_true Constants["Boolean"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Boolean"].lookup("toString")
  end

  def test_equatable
    assert_true Constants["Boolean"].has_contract(Constants["Equatable"].ruby_value)
    assert_not_nil Constants["Boolean"].lookup("==")
    assert_not_nil Constants["Boolean"].lookup("!=")
  end

end

