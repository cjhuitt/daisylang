require "test_helper"
require "lexer"
class LexerTest < Test::Unit::TestCase
  def test_empty
    assert_equal [], Lexer.new.tokenize("")
  end

  def test_int
    assert_equal [[:INTEGER, 1]], Lexer.new.tokenize("1")
  end

  def test_string
    assert_equal [[:STRING, "Greetings  fools"]], Lexer.new.tokenize('"Greetings  fools"')
  end

  def test_string_with_linewraps
    code = "\"Greetings\n\n    fools\""
    assert_equal [[:STRING, "Greetings\n\n    fools"]], Lexer.new.tokenize(code)
  end

  def test_empty_line
    assert_equal [[:NEWLINE, "\n"]], Lexer.new.tokenize("\n")
  end

  def test_int_with_newline
    expected = [
      [:INTEGER, 5], [:NEWLINE, "\n"]
    ]
    assert_equal expected, Lexer.new.tokenize("5\n")
  end

  def test_ignores_whitespace_before_newlines
    expected = [
      [:IDENTIFIER, "a"], [:NEWLINE, "\n"]
    ]
    assert_equal expected, Lexer.new.tokenize("a    \t \n")
  end

  def test_recognizes_keywords
    assert_equal [[:FUNCTION, "Function"]], Lexer.new.tokenize("Function")
    assert_equal [[:RETURN, "return"]], Lexer.new.tokenize("return")
    assert_equal [[:NONE, "None"]], Lexer.new.tokenize("None")
    assert_equal [[:PASS, "pass"]], Lexer.new.tokenize("pass")
  end

  def test_recognizes_identifiers
    assert_equal [[:IDENTIFIER, "Integer"]], Lexer.new.tokenize("Integer")
  end

  def test_recognizes_operators
    assert_equal [[':', ":"]], Lexer.new.tokenize(":")
    assert_equal [['(', "("]], Lexer.new.tokenize("(")
    assert_equal [[')', ")"]], Lexer.new.tokenize(")")
    assert_equal [['=', " = "]], Lexer.new.tokenize(" = ")
    assert_equal [['+', " + "]], Lexer.new.tokenize(" + ")
    assert_equal [['-', " - "]], Lexer.new.tokenize(" - ")
    assert_equal [['*', " * "]], Lexer.new.tokenize(" * ")
    assert_equal [['/', " / "]], Lexer.new.tokenize(" / ")
    assert_equal [['^', " ^ "]], Lexer.new.tokenize(" ^ ")
  end

  def test_finds_multiple_tokens_on_a_line
    expected = [
      [:IDENTIFIER, "a"], ['+', " + "],
      [:IDENTIFIER, "b"], [:WHITESPACE, " "]
    ]
    assert_equal expected, Lexer.new.tokenize("a + b ")
  end

  def test_finds_multiple_tokens_without_whitespace
    expected = [
      ['(', "("], [:IDENTIFIER, "b"], [')', ")"]
    ]
    assert_equal expected, Lexer.new.tokenize("(b)")
  end

  def test_lexes_block_opening
    expected = [
      [:BLOCKSTART, 1]
    ]
    assert_equal expected, Lexer.new.tokenize("    ")
  end

  def test_lexes_block_closing
    expected = [
      [:BLOCKSTART, 1], [:NEWLINE, "\n"],
      [:BLOCKEND, 1], ['(', "("]
    ]
    assert_equal expected, Lexer.new.tokenize("    \n(")
  end

  def test_function
    code = <<-CODE
Function Integer Summation( n: Integer )
    return n * (n - 1) / 2

CODE
    expected = [
      [:FUNCTION, "Function"], [:WHITESPACE, " "], [:IDENTIFIER, "Integer"],
          [:WHITESPACE, " "], [:IDENTIFIER, "Summation"], ['(', "( "],
          [:IDENTIFIER, "n"], [':', ": "],
          [:IDENTIFIER, "Integer"], [')', " )"], [:NEWLINE, "\n"],
      [:BLOCKSTART, 1],
        [:RETURN, "return"], [:WHITESPACE, " "], [:IDENTIFIER, "n"],
          ['*', " * "], ['(', "("], [:IDENTIFIER, "n"],
          ['-', " - "], [:INTEGER, 1], [')', ")"],
          ['/', " / "], [:INTEGER, 2],
          [:NEWLINE, "\n"],
      [:BLOCKEND, 1], [:NEWLINE, "\n"]
    ]

  end

  def test_call_print_of_string
    code = <<-CODE
print( "Hello World" )
CODE
    expected = [
      [:IDENTIFIER, "print"], ['(', "("], [:WHITESPACE, " "],
      [:STRING, "Hello World"], [:WHITESPACE, " "], [')', ")"],
      [:NEWLINE, "\n"]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  # To Test
  # Illegal Indentation (too much indentation)
  # More Keywords
  # Multi-char operators
  # Comments
end
