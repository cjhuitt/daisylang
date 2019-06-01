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

end
