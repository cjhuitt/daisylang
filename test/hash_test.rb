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

end

