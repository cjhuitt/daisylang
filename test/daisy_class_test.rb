require "test_helper"
require "runtime/runtime"

class DaisyClassTest < Test::Unit::TestCase
  def test_type_matches
    daisy_class = DaisyClass.new("Test")
    assert_true daisy_class.is_type(daisy_class)
  end

  def test_superclass_type_matches
    daisy_class = DaisyClass.new("Test")
    class2 = DaisyClass.new("Foo", daisy_class)
    assert_true class2.is_type(daisy_class)
  end

  def test_type_mismatch
    daisy_class = DaisyClass.new("Test")
    class2 = DaisyClass.new("Foo")
    assert_false class2.is_type(daisy_class)
  end
end
