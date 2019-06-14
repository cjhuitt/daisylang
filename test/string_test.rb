require "test_helper"
require "runtime/runtime"

class DaisyStringTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("String")
  end

  def test_pretty_print
    assert_true Constants["String"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["String"].lookup("toString")
  end
end

