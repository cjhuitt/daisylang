require 'test_helper'
require 'parser'

class ParserTest < Test::Unit::TestCase
  def test_empty
    assert_equal Nodes.new([]), Parser.new.parse("")
  end
  
end
