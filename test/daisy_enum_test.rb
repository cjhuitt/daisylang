require "test_helper"
require "runtime/runtime"

class DaisyEnumTest < Test::Unit::TestCase
  def test_type_matches
    enum = DaisyEnumCategory.new("Test")
    assert_true enum.is_type(enum)
  end

  def test_type_mismatch
    enum = DaisyEnumCategory.new("Test")
    enum2 = DaisyEnumCategory.new("Foo")
    assert_false enum2.is_type(enum)
  end

  def test_enum_knows_how_many_entries_it_has
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    enum.add("B")
    enum.add("C")
    assert_equal 3, enum.entries.count
  end

  def test_enum_does_not_allow_repeat_type_names
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    assert_raise do
      enum.add("A")
    end
  end

  def test_enum_type_knows_id_as_string
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    a = enum.entries["A"]
    assert_not_nil a
    assert_equal "A", a.name
  end

  def test_enum_type_knows_enum_category
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    a = enum.entries["A"]
    assert_not_nil a
    assert_equal enum, a.category
  end

  def test_enum_type_knows_value
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    a = enum.entries["A"]
    assert_not_nil a
    assert_equal 0, a.value.ruby_value
  end

end
