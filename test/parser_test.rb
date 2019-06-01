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

  def test_message_with_receiver
    assert_equal Nodes.new([MessageNode.new("variable", "method", [])]),
      Parser.new.parse("variable.method()")
  end

  def test_message_no_receiver
    assert_equal Nodes.new([MessageNode.new(nil, "method", [])]),
      Parser.new.parse("method()")
  end

  def test_message_with_single_argument
    expected = Nodes.new([
      MessageNode.new(nil, "method", [
        ArgumentNode.new(nil, IntegerNode.new(13))
      ])
    ])
    assert_equal expected, Parser.new.parse("method(13)")
  end

  def test_message_with_single_labeled_argument
    expected = Nodes.new([
      MessageNode.new(nil, "method", [
        ArgumentNode.new("foo", IntegerNode.new(13))
      ])
    ])
    assert_equal expected, Parser.new.parse("method(foo: 13)")
  end

  def test_message_with_multiple_labeled_arguments
    expected = Nodes.new([
      MessageNode.new(nil, "method", [
        ArgumentNode.new("foo", IntegerNode.new(13)),
        ArgumentNode.new("bar", IntegerNode.new(42))
      ])
    ])
    assert_equal expected, Parser.new.parse("method(foo: 13, bar: 42)")
  end

  def test_return
    assert_equal Nodes.new([ReturnNode.new(IntegerNode.new(9))]),
      Parser.new.parse("return 9")
  end

  def test_operators_are_messages
    expected = Nodes.new([
      MessageNode.new(IntegerNode.new(73), "+", [
        ArgumentNode.new(nil, IntegerNode.new(42))
      ])
    ])
    assert_equal expected, Parser.new.parse("73 + 42")
  end

end
