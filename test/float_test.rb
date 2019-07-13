require "test_helper"
require "runtime/runtime"

class DaisyFloatTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Float", nil)
  end

  def test_immutable_math_operations_exist
#    assert_true Constants["Float"].has_contract(Constants["Numerical"].ruby_value)
    assert_not_nil Constants["Float"].lookup("+")
    assert_not_nil Constants["Float"].lookup("-")
    assert_not_nil Constants["Float"].lookup("*")
    assert_not_nil Constants["Float"].lookup("/")
    assert_not_nil Constants["Float"].lookup("^")
  end

  def test_comparison_operations_exist
    assert_true Constants["Float"].has_contract(Constants["Comperable"].ruby_value)
    assert_not_nil Constants["Float"].lookup("<")
    assert_not_nil Constants["Float"].lookup("<=")
    assert_not_nil Constants["Float"].lookup(">")
    assert_not_nil Constants["Float"].lookup(">=")
  end

  def test_comparison_operations
    one = Constants["Float"].new(1.0)
    two = Constants["Float"].new(2.0)

    less = one.runtime_class.lookup("<")
    assert_equal Constants["Boolean"], less.call(nil, one, [[nil, two]]).runtime_class
    assert_equal Constants["true"], less.call(nil, one, [[nil, two]])
    assert_equal Constants["false"], less.call(nil, two, [[nil, one]])

    le = one.runtime_class.lookup("<=")
    assert_equal Constants["Boolean"], le.call(nil, one, [[nil, two]]).runtime_class
    assert_equal Constants["true"], le.call(nil, one, [[nil, two]])
    assert_equal Constants["true"], le.call(nil, one, [[nil, one]])
    assert_equal Constants["false"], le.call(nil, two, [[nil, one]])

    greater = one.runtime_class.lookup(">")
    assert_equal Constants["Boolean"], greater.call(nil, one, [[nil, two]]).runtime_class
    assert_equal Constants["false"], greater.call(nil, one, [[nil, two]])
    assert_equal Constants["true"], greater.call(nil, two, [[nil, one]])

    ge = one.runtime_class.lookup(">=")
    assert_equal Constants["Boolean"], ge.call(nil, one, [[nil, two]]).runtime_class
    assert_equal Constants["false"], ge.call(nil, one, [[nil, two]])
    assert_equal Constants["true"], ge.call(nil, one, [[nil, one]])
    assert_equal Constants["true"], ge.call(nil, two, [[nil, one]])
  end

  def test_equatable
    assert_true Constants["Float"].has_contract(Constants["Equatable"].ruby_value)
    assert_not_nil Constants["Float"].lookup("==")
    assert_not_nil Constants["Float"].lookup("!=")
  end

  def test_verifiable
    assert_true Constants["Float"].has_contract(Constants["Verifiable"].ruby_value)
    assert_not_nil Constants["Float"].lookup("?")
  end

  def test_stringifiable
    assert_true Constants["Float"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Float"].lookup("toString")
  end
end

