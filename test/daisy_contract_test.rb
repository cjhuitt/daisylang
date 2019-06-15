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
end
