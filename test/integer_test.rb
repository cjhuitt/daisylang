require "test_helper"
require "runtime/runtime"

class DaisyIntegerTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Integer")
  end

  def test_immutable_math_operations_exist
    assert_not_nil Constants["Integer"].lookup("+")
    assert_not_nil Constants["Integer"].lookup("-")
    assert_not_nil Constants["Integer"].lookup("*")
    assert_not_nil Constants["Integer"].lookup("/")
    assert_not_nil Constants["Integer"].lookup("^")
  end

  def test_comparison_operations_exist
    assert_not_nil Constants["Integer"].lookup("<")
    assert_not_nil Constants["Integer"].lookup("<=")
    assert_not_nil Constants["Integer"].lookup(">")
    assert_not_nil Constants["Integer"].lookup(">=")
  end

  def test_logical_operations_exist
    assert_not_nil Constants["Integer"].lookup("?")
  end

  def test_pretty_print
    assert_true Constants["Integer"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Integer"].lookup("toString")
  end
end

