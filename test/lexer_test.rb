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
    assert_equal [[:RETURN, "return"]], Lexer.new.tokenize("return")
    assert_equal [[:PASS, "pass"]], Lexer.new.tokenize("pass")
    assert_equal [[:IF, "if"]], Lexer.new.tokenize("if")
    assert_equal [[:UNLESS, "unless"]], Lexer.new.tokenize("unless")
    assert_equal [[:TRUE, "true"]], Lexer.new.tokenize("true")
    assert_equal [[:FALSE, "false"]], Lexer.new.tokenize("false")
    assert_equal [[:NONE, "none"]], Lexer.new.tokenize("none")
  end

  def test_recognizes_identifiers
    assert_equal [[:IDENTIFIER, "Integer"]], Lexer.new.tokenize("Integer")
    assert_equal [[:IDENTIFIER, "None"]], Lexer.new.tokenize("None")
    assert_equal [[:IDENTIFIER, "Function"]], Lexer.new.tokenize("Function")
    assert_equal [[:FUNCTION, "Function:"]], Lexer.new.tokenize("Function: ")
    assert_equal [[:IDENTIFIER, "Class"]], Lexer.new.tokenize("Class")
    assert_equal [[:CONTRACT, "Contract:"]], Lexer.new.tokenize("Contract: ")
    assert_equal [[:IDENTIFIER, "Contract"]], Lexer.new.tokenize("Contract")
    assert_equal [[:CLASS, "Class:"]], Lexer.new.tokenize("Class: ")
  end

  def test_recognizes_simple_operators
    assert_equal [['=', " = "]], Lexer.new.tokenize(" = ")
    assert_equal [['+', " + "]], Lexer.new.tokenize(" + ")
    assert_equal [['-', " - "]], Lexer.new.tokenize(" - ")
    assert_equal [['*', " * "]], Lexer.new.tokenize(" * ")
    assert_equal [['/', " / "]], Lexer.new.tokenize(" / ")
    assert_equal [['^', " ^ "]], Lexer.new.tokenize(" ^ ")
    assert_equal [[':', ": "]], Lexer.new.tokenize(": ")
    assert_equal [[',', ", "]], Lexer.new.tokenize(", ")
    assert_equal [['( ', "( "]], Lexer.new.tokenize("( ")
    assert_equal [[' )', " )"]], Lexer.new.tokenize(" )")
    assert_equal [['(', "("]], Lexer.new.tokenize("(")
    assert_equal [[')', ")"]], Lexer.new.tokenize(")")
    assert_equal [['?', "?"]], Lexer.new.tokenize("?")
    assert_equal [['!', "!"]], Lexer.new.tokenize("!")
  end

  def test_recognizes_multichar_operators
    assert_equal [['&&', "&&"]], Lexer.new.tokenize("&&")
    assert_equal [['||', "||"]], Lexer.new.tokenize("||")
    assert_equal [['==', "=="]], Lexer.new.tokenize("==")
    assert_equal [['!=', "!="]], Lexer.new.tokenize("!=")
    assert_equal [['>=', ">="]], Lexer.new.tokenize(">=")
    assert_equal [['<=', "<="]], Lexer.new.tokenize("<=")
  end

  def test_finds_multiple_tokens_on_a_line
    expected = [
      [:IDENTIFIER, "a"], ['+', " + "],
      [:IDENTIFIER, "b"]
    ]
    assert_equal expected, Lexer.new.tokenize("a + b ")
  end

  def test_finds_multiple_strings_on_a_line
    expected = [
      [:STRING, "a"], ['+', " + "], [:STRING, "b"]
    ]
    assert_equal expected, Lexer.new.tokenize('"a" + "b"')
  end

  def test_finds_multiple_tokens_without_whitespace
    expected = [
      ['(', "("], [:IDENTIFIER, "b"], [')', ")"]
    ]
    assert_equal expected, Lexer.new.tokenize("(b)")
  end

  def test_lexes_block_opening
    expected = [
      [:IDENTIFIER, "a"],
      [:BLOCKSTART, 1]
    ]
    assert_equal expected, Lexer.new.tokenize("a\n    ")
  end

  def test_lexes_block_closing
    expected = [
      [:BLOCKSTART, 1],
      [:BLOCKEND, 1], ['(', "("]
    ]
    assert_equal expected, Lexer.new.tokenize("    \n(")
  end

  def test_function
    code = <<-CODE
Function: Integer Summation( n: Integer )
    return n * (n - 1) / 2

CODE
    expected = [
      [:FUNCTION, "Function:"], [:IDENTIFIER, "Integer"],
          [:IDENTIFIER, "Summation"], ['( ', "( "],
          [:IDENTIFIER, "n"], [':', ": "],
          [:IDENTIFIER, "Integer"], [' )', " )"], [:NEWLINE, "\n"],
      [:BLOCKSTART, 1],
        [:RETURN, "return"], [:IDENTIFIER, "n"],
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
      [:IDENTIFIER, "print"], ['( ', "( "],
      [:STRING, "Hello World"], [' )', " )"],
      [:NEWLINE, "\n"]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_call_method_on_variable
    expected = [
      [:IDENTIFIER, "a"], ['.', "."], [:IDENTIFIER, "b"],
      ['()', "()"]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b()")
  end

  def test_member_variable
    expected = [
      [:IDENTIFIER, "a"], [:FIELD, "b"]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b")
  end

  def test_call_method_with_multiple_parameters
    code = <<-CODE
Greet( name: "Caleb", greeting: "Hey" )
CODE
    expected = [
      [:IDENTIFIER, "Greet"], ['( ', "( "],
      [:IDENTIFIER, "name"], [':', ": "], [:STRING, "Caleb"], [',', ", "],
      [:IDENTIFIER, "greeting"], [':', ": "], [:STRING, "Hey"],
      [' )', " )"], [:NEWLINE, "\n"]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_comment
    expected = [
      [:COMMENT, "// true"]
    ]
    assert_equal expected, Lexer.new.tokenize("// true")
  end

  def test_distinguishes_potentially_ambiguous_portions
    assert_equal [[:IDENTIFIER, "a"],
                  ["?", "?"]], Lexer.new.tokenize("a?")
    assert_equal [[:IDENTIFIER, "b"],
                  ['.', "."],
                  [:IDENTIFIER, "a?"],
                  ['()', "()"]], Lexer.new.tokenize("b.a?()")
    assert_equal [[:IDENTIFIER, "a?"],
                  ['()', "()"]], Lexer.new.tokenize("a?()")
    assert_equal [[:IDENTIFIER, "a?"],
                  ['( ', "( "],
                  [:IDENTIFIER, "b"],
                  [' )', " )"]], Lexer.new.tokenize("a?( b )")
    assert_equal [[:IS, "is"]], Lexer.new.tokenize("is ")
    assert_equal [[:IDENTIFIER, "is"],
                  ["?", "?"]], Lexer.new.tokenize("is?")
  end

  def x_test_print_tokens
    code = <<-CODE
Function: Integer fibonacci( n: Integer )
    if n <= 2
        return 1
    return fibonacci( n - 1 ) + fibonacci( n - 2 )

CODE
    puts "#{Lexer.new.tokenize(code)}"
  end

  # To Test
  # Illegal Indentation (too much indentation)
  # More Keywords
end
