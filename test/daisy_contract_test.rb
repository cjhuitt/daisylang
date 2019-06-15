require "test_helper"
require "runtime/runtime"

class DaisyContractTest < Test::Unit::TestCase
  def test_type_matches
    contract = DaisyContract.new("Test")
    assert_true contract.is_type(contract)
  end

  def test_type_mismatch
    contract = DaisyContract.new("Test")
    contract2 = DaisyContract.new("Foo")
    assert_false contract2.is_type(contract)
  end

  def test_lookup_finds_ruby_defined_method
    contract = DaisyContract.new("Test")
    contract.def :foo do |passed_interpreter, passed_receiver, passed_args|
    end
    assert_true contract.defines?("foo")
    method = contract.lookup("foo")
    assert_not_nil method
  end

  def test_lookup_finds_daisy_defined_method
    contract = DaisyContract.new("Test")
    method = DaisyMethod.new("foo", Constants["None"], {}, [])
    contract.add_method(method)
    assert_true contract.defines?("foo")
    method = contract.lookup("foo")
    assert_not_nil method
  end

  def test_lookup_does_not_find_method_from_different_contract
    contract = DaisyContract.new("Test")
    contract.def :foo do |passed_interpreter, passed_receiver, passed_args|
    end
    contract2 = DaisyContract.new("Foo")
    assert_false contract2.defines?("foo")
    method = contract2.lookup("foo")
    assert_nil method
  end

end
