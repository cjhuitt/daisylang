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

  def test_lookup_finds_defined_method
    daisy_class = DaisyClass.new("Test")
    run = false
    daisy_class.def :foo do |passed_interpreter, passed_receiver, passed_args|
      run = true
    end
    method = daisy_class.lookup("foo")
    assert_not_nil method
    assert_false run
    method.call("1", "2", "3")
    assert_true run
  end

  def test_lookup_finds_method_defined_in_superclass
    daisy_class = DaisyClass.new("Test")
    run = false
    daisy_class.def :foo do |passed_interpreter, passed_receiver, passed_args|
      run = true
    end
    class2 = DaisyClass.new("Foo", daisy_class)
    method = class2.lookup("foo")
    assert_not_nil method
    assert_false run
    method.call("1", "2", "3")
    assert_true run
  end

  def test_lookup_does_not_find_method_from_different_class
    daisy_class = DaisyClass.new("Test")
    run = false
    daisy_class.def :foo do |passed_interpreter, passed_receiver, passed_args|
      run = true
    end
    class2 = DaisyClass.new("Foo")
    method = class2.lookup("foo")
    assert_nil method
  end

  def test_class_in_root_context
    assert_not_nil RootContext.symbol("Class")
  end

  def test_equality_operations_exists
    assert_not_nil Constants["Class"].lookup("==")
    assert_not_nil Constants["Class"].lookup("!=")
  end

  def test_creation_functions_exist
    assert_not_nil Constants["Class"].lookup("default")
  end

  def test_pretty_print_exists
    assert_not_nil Constants["Class"].lookup("printable")
  end
end
