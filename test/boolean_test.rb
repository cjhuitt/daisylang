require "test_helper"
require "runtime/runtime"

class DaisyBooleanTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Boolean")
  end

  def test_constants_for_only_values
    assert_not_nil Constants.key?("true")
    assert_not_nil Constants.key?("false")
  end
end

