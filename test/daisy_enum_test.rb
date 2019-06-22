require "test_helper"
require "runtime/runtime"

class DaisyEnumTest < Test::Unit::TestCase
  def test_type_matches
    enum = DaisyEnum.new("Test")
    assert_true enum.is_type(enum)
  end

  def test_type_mismatch
    enum = DaisyEnum.new("Test")
    enum2 = DaisyEnum.new("Foo")
    assert_false enum2.is_type(enum)
  end

end
