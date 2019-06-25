require "test_helper"
require "lexer"

class LexerTest < Test::Unit::TestCase
  def test_empty
    assert_equal [], Lexer.new.tokenize("")
  end

  def test_int
    expected = [[:INTEGER, LexedChunk.new(1, 1)]]
    assert_equal expected, Lexer.new.tokenize("1")
  end

  def test_string
    expected = [[:STRING, LexedChunk.new("Greetings  fools", 1)]]
    assert_equal expected, Lexer.new.tokenize('"Greetings  fools"')
  end

  def test_string_with_linewraps
    code = "\"Greetings\n\n    fools\""
    expected = [[:STRING, LexedChunk.new("Greetings\n\n    fools", 1)]]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_empty_line
    expected = [[:NEWLINE, LexedChunk.new("\n", 1)]]
    assert_equal expected, Lexer.new.tokenize("\n")
  end

  def test_int_with_newline
    expected = [
      [:INTEGER, LexedChunk.new(5, 1)], [:NEWLINE, LexedChunk.new("\n", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("5\n")
  end

  def test_ignores_whitespace_before_newlines
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", 1)], [:NEWLINE, LexedChunk.new("\n", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("a    \t \n")
  end

  def test_recognizes_keywords
    expected = [[:IF, LexedChunk.new("if", 1)]]
    assert_equal expected, Lexer.new.tokenize("if")
    expected = [[:ELSE, LexedChunk.new("else", 1)]]
    assert_equal expected, Lexer.new.tokenize("else")
    expected = [[:UNLESS, LexedChunk.new("unless", 1)]]
    assert_equal expected, Lexer.new.tokenize("unless")
    expected = [[:WHILE, LexedChunk.new("while", 1)]]
    assert_equal expected, Lexer.new.tokenize("while")
    expected = [[:LOOP, LexedChunk.new("loop", 1)]]
    assert_equal expected, Lexer.new.tokenize("loop")
    expected = [[:SWITCH, LexedChunk.new("switch", 1)]]
    assert_equal expected, Lexer.new.tokenize("switch")
    expected = [[:CASE, LexedChunk.new("case", 1)]]
    assert_equal expected, Lexer.new.tokenize("case")

    expected = [[:BREAK, LexedChunk.new("break", 1)]]
    assert_equal expected, Lexer.new.tokenize("break")
    expected = [[:CONTINUE, LexedChunk.new("continue", 1)]]
    assert_equal expected, Lexer.new.tokenize("continue")
    expected = [[:PASS, LexedChunk.new("pass", 1)]]
    assert_equal expected, Lexer.new.tokenize("pass")
    expected = [[:RETURN, LexedChunk.new("return", 1)]]
    assert_equal expected, Lexer.new.tokenize("return")

    expected = [[:TRUE, LexedChunk.new("true", 1)]]
    assert_equal expected, Lexer.new.tokenize("true")
    expected = [[:FALSE, LexedChunk.new("false", 1)]]
    assert_equal expected, Lexer.new.tokenize("false")
    expected = [[:NONE, LexedChunk.new("none", 1)]]
    assert_equal expected, Lexer.new.tokenize("none")
  end

  def test_recognizes_identifiers
    expected = [[:IDENTIFIER, LexedChunk.new("Integer", 1)]]
    assert_equal expected, Lexer.new.tokenize("Integer")
    expected = [[:IDENTIFIER, LexedChunk.new("None", 1)]]
    assert_equal expected, Lexer.new.tokenize("None")
    expected = [[:IDENTIFIER, LexedChunk.new("Method", 1)]]
    assert_equal expected, Lexer.new.tokenize("Method")
    expected = [[:METHOD, LexedChunk.new("Method:", 1)]]
    assert_equal expected, Lexer.new.tokenize("Method: ")
    expected = [[:IDENTIFIER, LexedChunk.new("Class", 1)]]
    assert_equal expected, Lexer.new.tokenize("Class")
    expected = [[:CONTRACT, LexedChunk.new("Contract:", 1)]]
    assert_equal expected, Lexer.new.tokenize("Contract: ")
    expected = [[:IDENTIFIER, LexedChunk.new("Contract", 1)]]
    assert_equal expected, Lexer.new.tokenize("Contract")
    expected = [[:CLASS, LexedChunk.new("Class:", 1)]]
    assert_equal expected, Lexer.new.tokenize("Class: ")
    expected = [[:ENUM, LexedChunk.new("Enumerate:", 1)]]
    assert_equal expected, Lexer.new.tokenize("Enumerate: ")
  end

  def test_recognizes_simple_operators
    expected = [['=', LexedChunk.new(" = ", 1)]]
    assert_equal expected, Lexer.new.tokenize(" = ")
    expected = [['+', LexedChunk.new(" + ", 1)]]
    assert_equal expected, Lexer.new.tokenize(" + ")
    expected = [['-', LexedChunk.new(" - ", 1)]]
    assert_equal expected, Lexer.new.tokenize(" - ")
    expected = [['*', LexedChunk.new(" * ", 1)]]
    assert_equal expected, Lexer.new.tokenize(" * ")
    expected = [['/', LexedChunk.new(" / ", 1)]]
    assert_equal expected, Lexer.new.tokenize(" / ")
    expected = [['^', LexedChunk.new(" ^ ", 1)]]
    assert_equal expected, Lexer.new.tokenize(" ^ ")
    expected = [[':', LexedChunk.new(": ", 1)]]
    assert_equal expected, Lexer.new.tokenize(": ")
    expected = [[',', LexedChunk.new(", ", 1)]]
    assert_equal expected, Lexer.new.tokenize(", ")
    expected = [[',', LexedChunk.new(", ", 1)]]
    assert_equal expected, Lexer.new.tokenize(",\n")
    expected = [['( ', LexedChunk.new("( ", 1)]]
    assert_equal expected, Lexer.new.tokenize("( ")
    expected = [[' )', LexedChunk.new(" )", 1)]]
    assert_equal expected, Lexer.new.tokenize(" )")
    expected = [['(', LexedChunk.new("(", 1)]]
    assert_equal expected, Lexer.new.tokenize("(")
    expected = [[')', LexedChunk.new(")", 1)]]
    assert_equal expected, Lexer.new.tokenize(")")
    expected = [['?', LexedChunk.new("?", 1)]]
    assert_equal expected, Lexer.new.tokenize("?")
    expected = [['!', LexedChunk.new("!", 1)]]
    assert_equal expected, Lexer.new.tokenize("!")
    expected = [['[', LexedChunk.new("[", 1)]]
    assert_equal expected, Lexer.new.tokenize("[")
    expected = [[']', LexedChunk.new("]", 1)]]
    assert_equal expected, Lexer.new.tokenize("]")
    expected = [['{', LexedChunk.new("{", 1)]]
    assert_equal expected, Lexer.new.tokenize("{")
    expected = [['}', LexedChunk.new("}", 1)]]
    assert_equal expected, Lexer.new.tokenize("}")
    expected = [['#', LexedChunk.new("#", 1)]]
    assert_equal expected, Lexer.new.tokenize("#")
  end

  def test_recognizes_multichar_operators
    expected = [['&&', LexedChunk.new("&&", 1)]]
    assert_equal expected, Lexer.new.tokenize("&&")
    expected = [['||', LexedChunk.new("||", 1)]]
    assert_equal expected, Lexer.new.tokenize("||")
    expected = [['==', LexedChunk.new("==", 1)]]
    assert_equal expected, Lexer.new.tokenize("==")
    expected = [['!=', LexedChunk.new("!=", 1)]]
    assert_equal expected, Lexer.new.tokenize("!=")
    expected = [['>=', LexedChunk.new(">=", 1)]]
    assert_equal expected, Lexer.new.tokenize(">=")
    expected = [['<=', LexedChunk.new("<=", 1)]]
    assert_equal expected, Lexer.new.tokenize("<=")
    expected = [['=>', LexedChunk.new("=>", 1)]]
    assert_equal expected, Lexer.new.tokenize("=>")
  end

  def test_finds_multiple_tokens_on_a_line
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", 1)], ['+', LexedChunk.new(" + ", 1)],
      [:IDENTIFIER, LexedChunk.new("b", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("a + b ")
  end

  def test_finds_multiple_strings_on_a_line
    expected = [
      [:STRING, LexedChunk.new("a", 1)], ['+', LexedChunk.new(" + ", 1)], [:STRING, LexedChunk.new("b", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize('"a" + "b"')
  end

  def test_finds_multiple_tokens_without_whitespace
    expected = [
      ['(', LexedChunk.new("(", 1)], [:IDENTIFIER, LexedChunk.new("b", 1)], [')', LexedChunk.new(")", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("(b)")
  end

  def test_lexes_block_opening
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", 1)],
      [:BLOCKSTART, LexedChunk.new(1, 2)]
    ]
    assert_equal expected, Lexer.new.tokenize("a\n    ")
  end

  def test_lexes_block_closing
    expected = [
      [:BLOCKSTART, LexedChunk.new(1, 1)],
      [:BLOCKEND, LexedChunk.new(1, 2)], ['(', LexedChunk.new("(", 2)]
    ]
    assert_equal expected, Lexer.new.tokenize("    \n(")
  end

  def test_method
    code = <<-CODE
Method: Integer Summation( n: Integer )
    return n * (n - 1) / 2

CODE
    expected = [
      [:METHOD, LexedChunk.new("Method:", 1)], [:IDENTIFIER, LexedChunk.new("Integer", 1)],
          [:IDENTIFIER, LexedChunk.new("Summation", 1)], ['( ', LexedChunk.new("( ", 1)],
          [:IDENTIFIER, LexedChunk.new("n", 1)], [':', LexedChunk.new(": ", 1)],
          [:IDENTIFIER, LexedChunk.new("Integer", 1)], [' )', LexedChunk.new(" )", 1)],
        [:BLOCKSTART, LexedChunk.new(1, 2)],
        [:RETURN, LexedChunk.new("return", 2)], [:IDENTIFIER, LexedChunk.new("n", 2)],
          ['*', LexedChunk.new(" * ", 2)], ['(', LexedChunk.new("(", 2)], [:IDENTIFIER, LexedChunk.new("n", 2)],
          ['-', LexedChunk.new(" - ", 2)], [:INTEGER, LexedChunk.new(1, 2)], [')', LexedChunk.new(")", 2)],
          ['/', LexedChunk.new(" / ", 2)], [:INTEGER, LexedChunk.new(2, 2)],
        [:BLOCKEND, LexedChunk.new(1, 3)], [:NEWLINE, LexedChunk.new("\n", 3)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_call_print_of_string
    code = <<-CODE
print( "Hello World" )
CODE
    expected = [
      [:IDENTIFIER, LexedChunk.new("print", 1)], ['( ', LexedChunk.new("( ", 1)],
      [:STRING, LexedChunk.new("Hello World", 1)], [' )', LexedChunk.new(" )", 1)],
      [:NEWLINE, LexedChunk.new("\n", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_call_method_on_variable
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", 1)], ['.', LexedChunk.new(".", 1)], [:IDENTIFIER, LexedChunk.new("b", 1)],
      ['()', LexedChunk.new("()", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b()")
  end

  def test_member_variable
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", 1)], [:FIELD, LexedChunk.new("b", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b")
  end

  def test_member_variable_in_subexpression
    expected = [
      ['(', LexedChunk.new("(", 1)],
      [:IDENTIFIER, LexedChunk.new("a", 1)], [:FIELD, LexedChunk.new("b", 1)],
      ['+', LexedChunk.new(" + ", 1)],
      [:IDENTIFIER, LexedChunk.new("a", 1)], [:FIELD, LexedChunk.new("b", 1)],
      [')', LexedChunk.new(")", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("(a.b + a.b)")
  end

  def test_call_method_with_multiple_parameters
    code = <<-CODE
Greet( name: "Caleb", greeting: "Hey" )
CODE
    expected = [
      [:IDENTIFIER, LexedChunk.new("Greet", 1)], ['( ', LexedChunk.new("( ", 1)],
      [:IDENTIFIER, LexedChunk.new("name", 1)], [':', LexedChunk.new(": ", 1)], [:STRING, LexedChunk.new("Caleb", 1)], [',', LexedChunk.new(", ", 1)],
      [:IDENTIFIER, LexedChunk.new("greeting", 1)], [':', LexedChunk.new(": ", 1)], [:STRING, LexedChunk.new("Hey", 1)],
      [' )', LexedChunk.new(" )", 1)], [:NEWLINE, LexedChunk.new("\n", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_comment
    expected = [
      [:COMMENT, LexedChunk.new("// true", 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("// true")
  end

  def test_distinguishes_potentially_ambiguous_portions
    expected = [[:IDENTIFIER, LexedChunk.new("a", 1)],
                ["?", LexedChunk.new("?", 1)]]
    assert_equal expected, Lexer.new.tokenize("a?")
    expected = [[:IDENTIFIER, LexedChunk.new("b", 1)],
                ['.', LexedChunk.new(".", 1)],
                [:IDENTIFIER, LexedChunk.new("a?", 1)],
                ['()', LexedChunk.new("()", 1)]]
    assert_equal expected, Lexer.new.tokenize("b.a?()")
    expected = [[:IDENTIFIER, LexedChunk.new("a?", 1)],
                ['()', LexedChunk.new("()", 1)]]
    assert_equal expected, Lexer.new.tokenize("a?()")
    expected = [[:IDENTIFIER, LexedChunk.new("a?", 1)],
                ['( ', LexedChunk.new("( ", 1)],
                [:IDENTIFIER, LexedChunk.new("b", 1)],
                [' )', LexedChunk.new(" )", 1)]]
    assert_equal expected, Lexer.new.tokenize("a?( b )")
    expected = [[:IS, LexedChunk.new("is", 1)]]
    assert_equal expected, Lexer.new.tokenize("is ")
    expected = [[:IDENTIFIER, LexedChunk.new("is", 1)],
                ["?", LexedChunk.new("?", 1)]]
    assert_equal expected, Lexer.new.tokenize("is?")
    expected = [["!", LexedChunk.new("!", 1)],
                [:IDENTIFIER, LexedChunk.new("a", 1)]]
    assert_equal expected, Lexer.new.tokenize("!a")
    expected = [[:IDENTIFIER, LexedChunk.new("b", 1)],
                ['.', LexedChunk.new(".", 1)],
                [:IDENTIFIER, LexedChunk.new("a!", 1)],
                ['()', LexedChunk.new("()", 1)]]
    assert_equal expected, Lexer.new.tokenize("b.a!()")
    expected = [[:FOR, LexedChunk.new("for", 1)],
                [:IDENTIFIER, LexedChunk.new("a", 1)],
                [:IN, LexedChunk.new("in", 1)],
                [:IDENTIFIER, LexedChunk.new("b", 1)]]
    assert_equal expected, Lexer.new.tokenize("for a in b")
    expected = [[:FOR, LexedChunk.new("for", 1)],
                [:IDENTIFIER, LexedChunk.new("a", 1)],
                [',', LexedChunk.new(", ", 1)],
                [:IDENTIFIER, LexedChunk.new("b", 1)],
                [:IN, LexedChunk.new("in", 1)],
                [:IDENTIFIER, LexedChunk.new("c", 1)]]
    assert_equal expected, Lexer.new.tokenize("for a, b in c")
    expected = [[:IDENTIFIER, LexedChunk.new("from", 1)], ['( ', LexedChunk.new("( ", 1)],
                [:IDENTIFIER, LexedChunk.new("in", 1)], [':', LexedChunk.new(": ", 1)],
                [:INTEGER, LexedChunk.new(0, 1)],
                [' )', LexedChunk.new(" )", 1)]]
    assert_equal expected, Lexer.new.tokenize("from( in: 0 )")
  end

  def test_for_construct
    code = <<-CODE
for a in b
    none

CODE
    expected = [
      [:FOR, LexedChunk.new("for", 1)],
      [:IDENTIFIER, LexedChunk.new("a", 1)], [:IN, LexedChunk.new("in", 1)],
      [:IDENTIFIER, LexedChunk.new("b", 1)],
      [:BLOCKSTART, LexedChunk.new(1, 2)],
        [:NONE, LexedChunk.new("none", 2)],
      [:BLOCKEND, LexedChunk.new(1, 3)], [:NEWLINE, LexedChunk.new("\n", 3)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def x_test_print_tokens
    code = <<-CODE
Method: Integer fibonacci( n: Integer )
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
