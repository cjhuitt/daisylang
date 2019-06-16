require "test_helper"
require "runtime/runtime"

class DaisyArrayTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Array", nil)
  end

  def test_stringifiable
    assert_true Constants["Array"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Array"].lookup("toString")
  end

  def test_concatable
    assert_not_nil Constants["Array"].lookup("+")
  end

  def test_verifiable
    assert_true Constants["Array"].has_contract(Constants["Verifiable"].ruby_value)
    assert_not_nil Constants["Array"].lookup("?")
  end

  def test_countable
    assert_true Constants["Array"].has_contract(Constants["Countable"].ruby_value)
    assert_not_nil Constants["Array"].lookup("empty?")
    assert_not_nil Constants["Array"].lookup("count")
  end

  def test_append_single_value
    append = Constants["Array"].lookup("append!")
    assert_not_nil append
    arr = Constants["Array"].new([1])
    append.call(nil, arr, [[nil, Constants["Integer"].new(2)]])
    assert_equal [1, 2], arr.ruby_value
  end

  def test_append_multiple_values
    append = Constants["Array"].lookup("append!")
    assert_not_nil append
    arr = Constants["Array"].new([1])
    append.call(nil, arr, [[nil, Constants["Integer"].new(2)],
                           [nil, Constants["Integer"].new(3)]])
    assert_equal [1, 2, 3], arr.ruby_value
  end

end

