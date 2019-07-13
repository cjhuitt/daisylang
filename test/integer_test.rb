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

  def test_immutable_op_promotion
    int = Constants["Integer"].new(1)
    float = Constants["Float"].new(2.0)

    add = int.runtime_class.lookup("+")
    assert_equal Constants["Float"], add.call(nil, int, [[nil, float]]).runtime_class
    assert_equal Constants["Float"], add.call(nil, float, [[nil, int]]).runtime_class

    sub = int.runtime_class.lookup("+")
    assert_equal Constants["Float"], sub.call(nil, int, [[nil, float]]).runtime_class
    assert_equal Constants["Float"], sub.call(nil, float, [[nil, int]]).runtime_class

    mult = int.runtime_class.lookup("+")
    assert_equal Constants["Float"], mult.call(nil, int, [[nil, float]]).runtime_class
    assert_equal Constants["Float"], mult.call(nil, float, [[nil, int]]).runtime_class

    div = int.runtime_class.lookup("+")
    assert_equal Constants["Float"], div.call(nil, int, [[nil, float]]).runtime_class
    assert_equal Constants["Float"], div.call(nil, float, [[nil, int]]).runtime_class

    exp = int.runtime_class.lookup("+")
    assert_equal Constants["Float"], exp.call(nil, int, [[nil, float]]).runtime_class
    assert_equal Constants["Float"], exp.call(nil, float, [[nil, int]]).runtime_class
  end

  def test_comparison_operations_exist
    assert_true Constants["Integer"].has_contract(Constants["Comperable"].ruby_value)
    assert_not_nil Constants["Integer"].lookup("<")
    assert_not_nil Constants["Integer"].lookup("<=")
    assert_not_nil Constants["Integer"].lookup(">")
    assert_not_nil Constants["Integer"].lookup(">=")
  end

  def test_comparison_operations
    one = Constants["Integer"].new(1)
    two = Constants["Integer"].new(2)

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

