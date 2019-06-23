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
    assert_equal 3, enum.values.count
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
    a = enum.values["A"]
    assert_not_nil a
    assert_equal "A", a.name
  end

  def test_enum_type_knows_enum_category
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    a = enum.values["A"]
    assert_not_nil a
    assert_equal enum, a.category
  end

  def test_enum_type_knows_value
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    a = enum.values["A"]
    assert_not_nil a
    assert_equal 0, a.value.ruby_value
  end

  def test_enum_category_is_iterable
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    enum.add("B")
    enum.add("C")
    assert_equal Enumerator, enum.each.class
  end

  def test_stringifiable
    assert_true Constants["EnumCategory"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["EnumCategory"].lookup("toString")
    assert_true Constants["EnumValue"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["EnumValue"].lookup("toString")
  end

  def test_category_reflection
    assert_not_nil Constants["EnumCategory"].lookup("name")
    assert_not_nil Constants["EnumCategory"].lookup("values")
  end

  def test_value_reflection
    assert_not_nil Constants["EnumValue"].lookup("name")
    assert_not_nil Constants["EnumValue"].lookup("value")
    assert_not_nil Constants["EnumValue"].lookup("category")
  end

  def test_enum_value_equality
    enum = DaisyEnumCategory.new("Test")
    enum.add("A")
    enum.add("B")
    a = enum.values["A"]
    b = enum.values["B"]
    assert_true a.== a
    assert_true a.eql? a
    assert_false a.== b
    assert_false a.eql? b

    enum2 = DaisyEnumCategory.new("Test2")
    enum2.add("A")
    a2 = enum2.values["A"]
    assert_true a.== a2
    assert_false a.eql? a2
  end

end
