require 'test_helper'
require 'parser'

class ParserTest < Test::Unit::TestCase
  def test_empty
    assert_equal Nodes.new([]), Parser.new.parse("")
  end

  def test_integer
    assert_equal Nodes.new([IntegerNode.new(7)]), Parser.new.parse("7")
  end

  # Newlines are required for certain parses but don't need to be nodes
  # (yet, at least)
  def test_newline
    assert_equal Nodes.new([]), Parser.new.parse("\n")
  end

  def test_integer_with_newline
    assert_equal Nodes.new([IntegerNode.new(7)]), Parser.new.parse("7\n")
  end

  def test_message_no_arguments
    assert_equal Nodes.new([SendMessageNode.new("variable", "method", [])]),
      Parser.new.parse("variable.method()")
  end

  def test_message_with_single_unlabeled_argument
    expected = Nodes.new([
      SendMessageNode.new(nil, "method", [
        ArgumentNode.new(nil, IntegerNode.new(13))
      ])
    ])
    assert_equal expected, Parser.new.parse("method(13)")
  end

  def test_message_with_single_labeled_argument
    expected = Nodes.new([
      SendMessageNode.new(nil, "method", [
        ArgumentNode.new("foo", IntegerNode.new(13))
      ])
    ])
    assert_equal expected, Parser.new.parse("method(foo: 13)")
  end

  def test_message_with_multiple_labeled_arguments
    expected = Nodes.new([
      SendMessageNode.new(nil, "method", [
        ArgumentNode.new("foo", IntegerNode.new(13)),
        ArgumentNode.new("bar", IntegerNode.new(42))
      ])
    ])
    assert_equal expected, Parser.new.parse("method(foo: 13, bar: 42)")
  end

  # Note: this is an error in the language, but the parser should make a
  # representation of it and let the later analysis handle erroring
  def test_message_with_multiple_unlabeled_arguments
    expected = Nodes.new([
      SendMessageNode.new("foo", "method", [
        ArgumentNode.new(nil, IntegerNode.new(13)),
        ArgumentNode.new(nil, IntegerNode.new(42))
      ])
    ])
    assert_equal expected, Parser.new.parse("foo.method(13, 42)")
  end

  def test_none
    assert_equal Nodes.new([NoneNode.new]), Parser.new.parse("None")
  end

  def test_pass
    assert_equal Nodes.new([PassNode.new]), Parser.new.parse("pass")
  end

  def test_return
    assert_equal Nodes.new([ReturnNode.new(IntegerNode.new(9))]),
      Parser.new.parse("return 9")
  end

  def test_operators_are_messages
    expected = Nodes.new([
      SendMessageNode.new(IntegerNode.new(73), "+", [
        ArgumentNode.new(nil, IntegerNode.new(42))
      ])
    ])
    assert_equal expected, Parser.new.parse("73 + 42")
  end

end
