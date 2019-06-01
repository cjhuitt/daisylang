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
        IntegerNode.new(13)
      ])
    ])
    assert_equal expected, Parser.new.parse("method(13)")
  end

end
