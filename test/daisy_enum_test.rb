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

  def test_enum_knows_how_many_types_it_has
    enum = DaisyEnum.new("Test")
    enum.add("A")
    enum.add("B")
    enum.add("C")
    assert_equal 3, enum.types.count
  end

  def test_enum_does_not_allow_repeat_type_names
    enum = DaisyEnum.new("Test")
    enum.add("A")
    assert_raise do
      enum.add("A")
    end
  end

  def test_enum_type_knows_id_as_string
    enum = DaisyEnum.new("Test")
    enum.add("A")
    a = enum.types["A"]
    assert_not_nil a
    assert_equal "A", a.name
  end

  def test_enum_type_knows_enum_collection
    enum = DaisyEnum.new("Test")
    enum.add("A")
    a = enum.types["A"]
    assert_not_nil a
    assert_equal enum, a.type
  end

  def test_enum_type_knows_value
    enum = DaisyEnum.new("Test")
    enum.add("A")
    a = enum.types["A"]
    assert_not_nil a
    assert_equal 0, a.value
  end

end
