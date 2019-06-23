require "test_helper"
require "runtime/runtime"

class DaisyHashTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Hash", nil)
  end

  def test_stringifiable
    assert_true Constants["Hash"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Hash"].lookup("toString")
  end

  def test_concatable
    assert_not_nil Constants["Hash"].lookup("+")
  end

  def test_verifiable
    assert_true Constants["Hash"].has_contract(Constants["Verifiable"].ruby_value)
    assert_not_nil Constants["Hash"].lookup("?")
  end

  def test_countable
    assert_true Constants["Hash"].has_contract(Constants["Countable"].ruby_value)
    assert_not_nil Constants["Hash"].lookup("empty?")
    assert_not_nil Constants["Hash"].lookup("count")
  end

  def test_indexable
    assert_true Constants["Hash"].has_contract(Constants["Indexable"].ruby_value)
    assert_not_nil Constants["Hash"].lookup("#")
  end

  def test_indexing_unknown_key_returns_none
    index = Constants["Hash"].lookup("#")
    assert_not_nil index
    hash = Constants["Hash"].new({Constants["Integer"].new(1) => Constants["Integer"].new(2)})
    returned = index.call(nil, hash, [[nil, Constants["Integer"].new(3)]])
    assert_equal Constants["none"], returned
  end

  def test_append_multiple_values
    append = Constants["Hash"].lookup("append!")
    assert_not_nil append
    hash = Constants["Hash"].new({1 => 2})
    append.call(nil, hash, [[nil, Constants["Hash"].new({3 => 4})]])
    assert_equal({ 1 => 2, 3 => 4 }, hash.ruby_value)
  end

  def test_access_components
    assert_not_nil Constants["Hash"].lookup("keys")
    assert_not_nil Constants["Hash"].lookup("values")
  end

end

