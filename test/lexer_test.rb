require "test_helper"
require "lexer"
class LexerTest < Test::Unit::TestCase
  def test_int
    assert_equal [[:INTEGER, 1]], Lexer.new.tokenize("1")
  end

  def test_newlines
    assert_equal [[:NEWLINE, "\n"]], Lexer.new.tokenize("\n")
  end

  def test_ignores_whitespace_before_newlines
    assert_equal [[:NEWLINE, "\n"]], Lexer.new.tokenize("    \t \n")
  end

  def xtest_function
    code = <<-CODE
Function Integer Summation(n: Integer)
    return n * (n - 1) / 2

CODE
  expected = [
    [:FUNCTION, "Function"], [:WHITESPACE, " "], [:IDENTIFIER, "Integer"],
        [:WHITESPACE, " "], [:IDENTIFIER, "Summation"], ['(', "("],
        [:IDENTIFIER, "n"], [':', ":"], [:WHITESPACE, " "],
        [:IDENTIFIER, "Integer"], [')', ")"], [:NEWLINE, "\n"],
    [:BLOCKSTART, 1],
      [:RETURN, "return"], [:WHITESPACE, " "], [:IDENTIFIER, "n"],
        [:WHITESPACE, " "], ['*', "*"], [:WHITESPACE, " "],
        ['(', "("], [:IDENTIFIER, "n"], [:WHITESPACE, " "],
        ['-', "-"], [:INTEGER, 1], [')', ")"], [:WHITESPACE, " "],
        ['/', "/"], [:WHITESPACE, " "], [:INTEGER, 2],
        [:NEWLINE, "\n"],
    [:BLOCKEND, 1], [:NEWLINE, "\n"]
  ]

  end
end
