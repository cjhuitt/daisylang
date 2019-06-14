require "test_helper"
require "runtime/runtime"

class DaisyStringTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("String")
  end

  def test_pretty_print
    assert_not_nil Constants["String"].lookup("printable")
  end
end

