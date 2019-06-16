require "test_helper"
require "runtime/runtime"

class DaisyStringTest < Test::Unit::TestCase
  def test_class_in_root_context
    assert_not_nil RootContext.symbol("String", nil)
  end

  def test_stringifiable
    assert_true Constants["String"].has_contract(Constants["Stringifiable"].ruby_value)
    assert_not_nil Constants["String"].lookup("toString")
  end

  def test_equatable
    assert_true Constants["String"].has_contract(Constants["Equatable"].ruby_value)
    assert_not_nil Constants["String"].lookup("==")
    assert_not_nil Constants["String"].lookup("!=")
  end

  def test_add_strings
    foo = Constants["String"].new("foo")
    bar = Constants["String"].new("bar")
    method = foo.runtime_class.lookup("+")
    foobar = method.call(nil, foo, [[nil, bar]])
    assert_equal Constants["String"], foobar.runtime_class
    assert_equal "foobar", foobar.ruby_value
  end
end

