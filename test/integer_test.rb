require "test_helper"
require "runtime/runtime"

class DaisyIntegerTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Integer")
  end

  def test_pretty_print
    assert_not_nil Constants["Integer"].lookup("printable")
  end
end

