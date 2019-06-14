require "test_helper"
require "runtime/runtime"

class DaisyBooleanTest < Test::Unit::TestCase
  def test_in_root_context
    assert_not_nil RootContext.symbol("Boolean")
  end

end

