require "test_helper"
require "lexer"

class LexerTest < Test::Unit::TestCase
  def test_empty
    assert_equal [], Lexer.new.tokenize("")
  end

  def test_int
    expected = [[:INTEGER, LexedChunk.new(1)]]
    assert_equal expected, Lexer.new.tokenize("1")
  end

  def test_string
    expected = [[:STRING, LexedChunk.new("Greetings  fools")]]
    assert_equal expected, Lexer.new.tokenize('"Greetings  fools"')
  end

  def test_string_with_linewraps
    code = "\"Greetings\n\n    fools\""
    expected = [[:STRING, LexedChunk.new("Greetings\n\n    fools")]]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_empty_line
    expected = [[:NEWLINE, LexedChunk.new("\n")]]
    assert_equal expected, Lexer.new.tokenize("\n")
  end

  def test_int_with_newline
    expected = [
      [:INTEGER, LexedChunk.new(5)], [:NEWLINE, LexedChunk.new("\n")]
    ]
    assert_equal expected, Lexer.new.tokenize("5\n")
  end

  def test_ignores_whitespace_before_newlines
    expected = [
      [:IDENTIFIER, LexedChunk.new("a")], [:NEWLINE, LexedChunk.new("\n")]
    ]
    assert_equal expected, Lexer.new.tokenize("a    \t \n")
  end

  def test_recognizes_keywords
    expected = [[:IF, LexedChunk.new("if")]]
    assert_equal expected, Lexer.new.tokenize("if")
    expected = [[:ELSE, LexedChunk.new("else")]]
    assert_equal expected, Lexer.new.tokenize("else")
    expected = [[:UNLESS, LexedChunk.new("unless")]]
    assert_equal expected, Lexer.new.tokenize("unless")
    expected = [[:WHILE, LexedChunk.new("while")]]
    assert_equal expected, Lexer.new.tokenize("while")
    expected = [[:LOOP, LexedChunk.new("loop")]]
    assert_equal expected, Lexer.new.tokenize("loop")
    expected = [[:SWITCH, LexedChunk.new("switch")]]
    assert_equal expected, Lexer.new.tokenize("switch")
    expected = [[:CASE, LexedChunk.new("case")]]
    assert_equal expected, Lexer.new.tokenize("case")

    expected = [[:BREAK, LexedChunk.new("break")]]
    assert_equal expected, Lexer.new.tokenize("break")
    expected = [[:CONTINUE, LexedChunk.new("continue")]]
    assert_equal expected, Lexer.new.tokenize("continue")
    expected = [[:PASS, LexedChunk.new("pass")]]
    assert_equal expected, Lexer.new.tokenize("pass")
    expected = [[:RETURN, LexedChunk.new("return")]]
    assert_equal expected, Lexer.new.tokenize("return")

    expected = [[:TRUE, LexedChunk.new("true")]]
    assert_equal expected, Lexer.new.tokenize("true")
    expected = [[:FALSE, LexedChunk.new("false")]]
    assert_equal expected, Lexer.new.tokenize("false")
    expected = [[:NONE, LexedChunk.new("none")]]
    assert_equal expected, Lexer.new.tokenize("none")
  end

  def test_recognizes_identifiers
    expected = [[:IDENTIFIER, LexedChunk.new("Integer")]]
    assert_equal expected, Lexer.new.tokenize("Integer")
    expected = [[:IDENTIFIER, LexedChunk.new("None")]]
    assert_equal expected, Lexer.new.tokenize("None")
    expected = [[:IDENTIFIER, LexedChunk.new("Method")]]
    assert_equal expected, Lexer.new.tokenize("Method")
    expected = [[:METHOD, LexedChunk.new("Method:")]]
    assert_equal expected, Lexer.new.tokenize("Method: ")
    expected = [[:IDENTIFIER, LexedChunk.new("Class")]]
    assert_equal expected, Lexer.new.tokenize("Class")
    expected = [[:CONTRACT, LexedChunk.new("Contract:")]]
    assert_equal expected, Lexer.new.tokenize("Contract: ")
    expected = [[:IDENTIFIER, LexedChunk.new("Contract")]]
    assert_equal expected, Lexer.new.tokenize("Contract")
    expected = [[:CLASS, LexedChunk.new("Class:")]]
    assert_equal expected, Lexer.new.tokenize("Class: ")
    expected = [[:ENUM, LexedChunk.new("Enumerate:")]]
    assert_equal expected, Lexer.new.tokenize("Enumerate: ")
  end

  def test_recognizes_simple_operators
    expected = [['=', " = "]]
    assert_equal expected, Lexer.new.tokenize(" = ")
    expected = [['+', " + "]]
    assert_equal expected, Lexer.new.tokenize(" + ")
    expected = [['-', " - "]]
    assert_equal expected, Lexer.new.tokenize(" - ")
    expected = [['*', " * "]]
    assert_equal expected, Lexer.new.tokenize(" * ")
    expected = [['/', " / "]]
    assert_equal expected, Lexer.new.tokenize(" / ")
    expected = [['^', " ^ "]]
    assert_equal expected, Lexer.new.tokenize(" ^ ")
    expected = [[':', ": "]]
    assert_equal expected, Lexer.new.tokenize(": ")
    expected = [[',', ", "]]
    assert_equal expected, Lexer.new.tokenize(", ")
    expected = [[',', ", "]]
    assert_equal expected, Lexer.new.tokenize(",\n")
    expected = [['( ', "( "]]
    assert_equal expected, Lexer.new.tokenize("( ")
    expected = [[' )', " )"]]
    assert_equal expected, Lexer.new.tokenize(" )")
    expected = [['(', "("]]
    assert_equal expected, Lexer.new.tokenize("(")
    expected = [[')', ")"]]
    assert_equal expected, Lexer.new.tokenize(")")
    expected = [['?', "?"]]
    assert_equal expected, Lexer.new.tokenize("?")
    expected = [['!', "!"]]
    assert_equal expected, Lexer.new.tokenize("!")
    expected = [['[', "["]]
    assert_equal expected, Lexer.new.tokenize("[")
    expected = [[']', "]"]]
    assert_equal expected, Lexer.new.tokenize("]")
    expected = [['{', "{"]]
    assert_equal expected, Lexer.new.tokenize("{")
    expected = [['}', "}"]]
    assert_equal expected, Lexer.new.tokenize("}")
    expected = [['#', "#"]]
    assert_equal expected, Lexer.new.tokenize("#")
  end

  def test_recognizes_multichar_operators
    expected = [['&&', "&&"]]
    assert_equal expected, Lexer.new.tokenize("&&")
    expected = [['||', "||"]]
    assert_equal expected, Lexer.new.tokenize("||")
    expected = [['==', "=="]]
    assert_equal expected, Lexer.new.tokenize("==")
    expected = [['!=', "!="]]
    assert_equal expected, Lexer.new.tokenize("!=")
    expected = [['>=', ">="]]
    assert_equal expected, Lexer.new.tokenize(">=")
    expected = [['<=', "<="]]
    assert_equal expected, Lexer.new.tokenize("<=")
    expected = [['=>', "=>"]]
    assert_equal expected, Lexer.new.tokenize("=>")
  end

  def test_finds_multiple_tokens_on_a_line
    expected = [
      [:IDENTIFIER, LexedChunk.new("a")], ['+', " + "],
      [:IDENTIFIER, LexedChunk.new("b")]
    ]
    assert_equal expected, Lexer.new.tokenize("a + b ")
  end

  def test_finds_multiple_strings_on_a_line
    expected = [
      [:STRING, LexedChunk.new("a")], ['+', " + "], [:STRING, LexedChunk.new("b")]
    ]
    assert_equal expected, Lexer.new.tokenize('"a" + "b"')
  end

  def test_finds_multiple_tokens_without_whitespace
    expected = [
      ['(', "("], [:IDENTIFIER, LexedChunk.new("b")], [')', ")"]
    ]
    assert_equal expected, Lexer.new.tokenize("(b)")
  end

  def test_lexes_block_opening
    expected = [
      [:IDENTIFIER, LexedChunk.new("a")],
      [:BLOCKSTART, LexedChunk.new(1)]
    ]
    assert_equal expected, Lexer.new.tokenize("a\n    ")
  end

  def test_lexes_block_closing
    expected = [
      [:BLOCKSTART, LexedChunk.new(1)],
      [:BLOCKEND, LexedChunk.new(1)], ['(', "("]
    ]
    assert_equal expected, Lexer.new.tokenize("    \n(")
  end

  def test_method
    code = <<-CODE
Method: Integer Summation( n: Integer )
    return n * (n - 1) / 2

CODE
    expected = [
      [:METHOD, LexedChunk.new("Method:")], [:IDENTIFIER, LexedChunk.new("Integer")],
          [:IDENTIFIER, LexedChunk.new("Summation")], ['( ', "( "],
          [:IDENTIFIER, LexedChunk.new("n")], [':', ": "],
          [:IDENTIFIER, LexedChunk.new("Integer")], [' )', " )"],
        [:BLOCKSTART, LexedChunk.new(1)],
        [:RETURN, LexedChunk.new("return")], [:IDENTIFIER, LexedChunk.new("n")],
          ['*', " * "], ['(', "("], [:IDENTIFIER, LexedChunk.new("n")],
          ['-', " - "], [:INTEGER, LexedChunk.new(1)], [')', ")"],
          ['/', " / "], [:INTEGER, LexedChunk.new(2)],
        [:BLOCKEND, LexedChunk.new(1)], [:NEWLINE, LexedChunk.new("\n")]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_call_print_of_string
    code = <<-CODE
print( "Hello World" )
CODE
    expected = [
      [:IDENTIFIER, LexedChunk.new("print")], ['( ', "( "],
      [:STRING, LexedChunk.new("Hello World")], [' )', " )"],
      [:NEWLINE, LexedChunk.new("\n")]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_call_method_on_variable
    expected = [
      [:IDENTIFIER, LexedChunk.new("a")], ['.', "."], [:IDENTIFIER, LexedChunk.new("b")],
      ['()', "()"]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b()")
  end

  def test_member_variable
    expected = [
      [:IDENTIFIER, LexedChunk.new("a")], [:FIELD, "b"]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b")
  end

  def test_member_variable_in_subexpression
    expected = [
      ['(', "("],
      [:IDENTIFIER, LexedChunk.new("a")], [:FIELD, "b"],
      ['+', " + "],
      [:IDENTIFIER, LexedChunk.new("a")], [:FIELD, "b"],
      [')', ")"]
    ]
    assert_equal expected, Lexer.new.tokenize("(a.b + a.b)")
  end

  def test_call_method_with_multiple_parameters
    code = <<-CODE
Greet( name: "Caleb", greeting: "Hey" )
CODE
    expected = [
      [:IDENTIFIER, LexedChunk.new("Greet")], ['( ', "( "],
      [:IDENTIFIER, LexedChunk.new("name")], [':', ": "], [:STRING, LexedChunk.new("Caleb")], [',', ", "],
      [:IDENTIFIER, LexedChunk.new("greeting")], [':', ": "], [:STRING, LexedChunk.new("Hey")],
      [' )', " )"], [:NEWLINE, LexedChunk.new("\n")]
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
    expected = [[:IDENTIFIER, LexedChunk.new("a")],
                ["?", "?"]]
    assert_equal expected, Lexer.new.tokenize("a?")
    expected = [[:IDENTIFIER, LexedChunk.new("b")],
                ['.', "."],
                [:IDENTIFIER, LexedChunk.new("a?")],
                ['()', "()"]]
    assert_equal expected, Lexer.new.tokenize("b.a?()")
    expected = [[:IDENTIFIER, LexedChunk.new("a?")],
                ['()', "()"]]
    assert_equal expected, Lexer.new.tokenize("a?()")
    expected = [[:IDENTIFIER, LexedChunk.new("a?")],
                ['( ', "( "],
                [:IDENTIFIER, LexedChunk.new("b")],
                [' )', " )"]]
    assert_equal expected, Lexer.new.tokenize("a?( b )")
    expected = [[:IS, "is"]]
    assert_equal expected, Lexer.new.tokenize("is ")
    expected = [[:IDENTIFIER, LexedChunk.new("is")],
                ["?", "?"]]
    assert_equal expected, Lexer.new.tokenize("is?")
    expected = [["!", "!"],
                [:IDENTIFIER, LexedChunk.new("a")]]
    assert_equal expected, Lexer.new.tokenize("!a")
    expected = [[:IDENTIFIER, LexedChunk.new("b")],
                ['.', "."],
                [:IDENTIFIER, LexedChunk.new("a!")],
                ['()', "()"]]
    assert_equal expected, Lexer.new.tokenize("b.a!()")
    expected = [[:FOR, "for"],
                [:IDENTIFIER, LexedChunk.new("a")],
                [:IN, "in"],
                [:IDENTIFIER, LexedChunk.new("b")]]
    assert_equal expected, Lexer.new.tokenize("for a in b")
    expected = [[:FOR, "for"],
                [:IDENTIFIER, LexedChunk.new("a")],
                [',', ", "],
                [:IDENTIFIER, LexedChunk.new("b")],
                [:IN, "in"],
                [:IDENTIFIER, LexedChunk.new("c")]]
    assert_equal expected, Lexer.new.tokenize("for a, b in c")
    expected = [[:IDENTIFIER, LexedChunk.new("from")], ['( ', "( "],
                [:IDENTIFIER, LexedChunk.new("in")], [':', ": "],
                [:INTEGER, LexedChunk.new(0)],
                [' )', " )"]]
    assert_equal expected, Lexer.new.tokenize("from( in: 0 )")
  end

  def test_for_construct
    code = <<-CODE
for a in b
    none

CODE
    expected = [
      [:FOR, "for"],
      [:IDENTIFIER, LexedChunk.new("a")], [:IN, "in"],
      [:IDENTIFIER, LexedChunk.new("b")],
      [:BLOCKSTART, LexedChunk.new(1)],
        [:NONE, LexedChunk.new("none")],
      [:BLOCKEND, LexedChunk.new(1)], [:NEWLINE, LexedChunk.new("\n")]
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
