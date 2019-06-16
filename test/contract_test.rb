require "test_helper"
require "runtime/runtime"

class ContractTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Contract", nil)
  end

  def test_stringifiable
    assert_not_nil RootContext.symbol("Stringifiable", nil)
    assert_not_nil Constants["Stringifiable"].runtime_class.lookup("toString")
    assert_true Constants["Contract"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["Contract"].lookup("toString")
  end

  def test_equatable
    assert_not_nil RootContext.symbol("Equatable", nil)
    assert_true Constants["Contract"].has_contract(Constants["Equatable"].ruby_value)
    assert_not_nil Constants["Equatable"].runtime_class.lookup("==")
    assert_not_nil Constants["Equatable"].runtime_class.lookup("!=")
    assert_not_nil Constants["Contract"].lookup("==")
    assert_not_nil Constants["Contract"].lookup("!=")
  end

  def test_comperable
    assert_not_nil RootContext.symbol("Comperable", nil)
    assert_not_nil Constants["Comperable"].runtime_class.lookup("<")
    assert_not_nil Constants["Comperable"].runtime_class.lookup("<=")
    assert_not_nil Constants["Comperable"].runtime_class.lookup(">")
    assert_not_nil Constants["Comperable"].runtime_class.lookup(">=")
  end

  def test_countable
    assert_not_nil RootContext.symbol("Countable", nil)
    assert_not_nil Constants["Countable"].runtime_class.lookup("empty?")
    assert_not_nil Constants["Countable"].runtime_class.lookup("count")
  end
end
