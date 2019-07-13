require "test_helper"
require "runtime/runtime"

class DaisyIntegerTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Integer", nil)
  end

  def test_immutable_math_operations_exist
#    assert_true Constants["Integer"].has_contract(Constants["Numerical"].ruby_value)
    assert_not_nil Constants["Integer"].lookup("+")
    assert_not_nil Constants["Integer"].lookup("-")
    assert_not_nil Constants["Integer"].lookup("*")
    assert_not_nil Constants["Integer"].lookup("/")
    assert_not_nil Constants["Integer"].lookup("^")
  end

  def test_comparison_operations_exist
    assert_true Constants["Integer"].has_contract(Constants["Comperable"].ruby_value)
    assert_not_nil Constants["Integer"].lookup("<")
    assert_not_nil Constants["Integer"].lookup("<=")
    assert_not_nil Constants["Integer"].lookup(">")
    assert_not_nil Constants["Integer"].lookup(">=")
  end

  def test_stringifiable
    assert_true Constants["Integer"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Integer"].lookup("toString")
  end

  def test_equatable
    assert_true Constants["Integer"].has_contract(Constants["Equatable"].ruby_value)
    assert_not_nil Constants["Integer"].lookup("==")
    assert_not_nil Constants["Integer"].lookup("!=")
  end

  def test_verifiable
    assert_true Constants["Integer"].has_contract(Constants["Verifiable"].ruby_value)
    assert_not_nil Constants["Integer"].lookup("?")
  end

  def test_convert_output
    assert_not_nil Constants["Integer"].lookup("toHex")
  end
end

