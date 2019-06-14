require "test_helper"
require "runtime/runtime"

class DaisyNoneTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("None")
  end

  def test_constant_for_only_value
    assert_not_nil Constants.key?("none")
  end

  def test_logical_operations_exist
    assert_not_nil Constants["None"].lookup("?")
  end

  def test_pretty_print
    assert_not_nil Constants["None"].lookup("printable")
  end
end
