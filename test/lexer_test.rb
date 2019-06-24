require "test_helper"
require "lexer"

class LexerTest < Test::Unit::TestCase
  def test_empty
    assert_equal [], Lexer.new.tokenize("")
  end

  def test_int
    expected = [[:INTEGER, 1]]
    assert_equal expected, Lexer.new.tokenize("1")
  end

  def test_string
    expected = [[:STRING, "Greetings  fools"]]
    assert_equal expected, Lexer.new.tokenize('"Greetings  fools"')
  end

  def test_string_with_linewraps
    code = "\"Greetings\n\n    fools\""
    expected = [[:STRING, "Greetings\n\n    fools"]]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_empty_line
    expected = [[:NEWLINE, "\n"]]
    assert_equal expected, Lexer.new.tokenize("\n")
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
    expected = [[:IF, "if"]]
    assert_equal expected, Lexer.new.tokenize("if")
    expected = [[:ELSE, "else"]]
    assert_equal expected, Lexer.new.tokenize("else")
    expected = [[:UNLESS, "unless"]]
    assert_equal expected, Lexer.new.tokenize("unless")
    expected = [[:WHILE, "while"]]
    assert_equal expected, Lexer.new.tokenize("while")
    expected = [[:LOOP, "loop"]]
    assert_equal expected, Lexer.new.tokenize("loop")
    expected = [[:SWITCH, "switch"]]
    assert_equal expected, Lexer.new.tokenize("switch")
    expected = [[:CASE, "case"]]
    assert_equal expected, Lexer.new.tokenize("case")

    expected = [[:BREAK, "break"]]
    assert_equal expected, Lexer.new.tokenize("break")
    expected = [[:CONTINUE, "continue"]]
    assert_equal expected, Lexer.new.tokenize("continue")
    expected = [[:PASS, "pass"]]
    assert_equal expected, Lexer.new.tokenize("pass")
    expected = [[:RETURN, "return"]]
    assert_equal expected, Lexer.new.tokenize("return")

    expected = [[:TRUE, "true"]]
    assert_equal expected, Lexer.new.tokenize("true")
    expected = [[:FALSE, "false"]]
    assert_equal expected, Lexer.new.tokenize("false")
    expected = [[:NONE, "none"]]
    assert_equal expected, Lexer.new.tokenize("none")
  end

  def test_recognizes_identifiers
    expected = [[:IDENTIFIER, "Integer"]]
    assert_equal expected, Lexer.new.tokenize("Integer")
    expected = [[:IDENTIFIER, "None"]]
    assert_equal expected, Lexer.new.tokenize("None")
    expected = [[:IDENTIFIER, "Method"]]
    assert_equal expected, Lexer.new.tokenize("Method")
    expected = [[:METHOD, "Method:"]]
    assert_equal expected, Lexer.new.tokenize("Method: ")
    expected = [[:IDENTIFIER, "Class"]]
    assert_equal expected, Lexer.new.tokenize("Class")
    expected = [[:CONTRACT, "Contract:"]]
    assert_equal expected, Lexer.new.tokenize("Contract: ")
    expected = [[:IDENTIFIER, "Contract"]]
    assert_equal expected, Lexer.new.tokenize("Contract")
    expected = [[:CLASS, "Class:"]]
    assert_equal expected, Lexer.new.tokenize("Class: ")
    expected = [[:ENUM, "Enumerate:"]]
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

  def test_method
    code = <<-CODE
Method: Integer Summation( n: Integer )
    return n * (n - 1) / 2

CODE
    expected = [
      [:METHOD, "Method:"], [:IDENTIFIER, "Integer"],
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

  def test_member_variable_in_subexpression
    expected = [
      ['(', "("],
      [:IDENTIFIER, "a"], [:FIELD, "b"],
      ['+', " + "],
      [:IDENTIFIER, "a"], [:FIELD, "b"],
      [')', ")"]
    ]
    assert_equal expected, Lexer.new.tokenize("(a.b + a.b)")
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
    expected = [[:IDENTIFIER, "a"],
                ["?", "?"]]
    assert_equal expected, Lexer.new.tokenize("a?")
    expected = [[:IDENTIFIER, "b"],
                ['.', "."],
                [:IDENTIFIER, "a?"],
                ['()', "()"]]
    assert_equal expected, Lexer.new.tokenize("b.a?()")
    expected = [[:IDENTIFIER, "a?"],
                ['()', "()"]]
    assert_equal expected, Lexer.new.tokenize("a?()")
    expected = [[:IDENTIFIER, "a?"],
                ['( ', "( "],
                [:IDENTIFIER, "b"],
                [' )', " )"]]
    assert_equal expected, Lexer.new.tokenize("a?( b )")
    expected = [[:IS, "is"]]
    assert_equal expected, Lexer.new.tokenize("is ")
    expected = [[:IDENTIFIER, "is"],
                ["?", "?"]]
    assert_equal expected, Lexer.new.tokenize("is?")
    expected = [["!", "!"],
                [:IDENTIFIER, "a"]]
    assert_equal expected, Lexer.new.tokenize("!a")
    expected = [[:IDENTIFIER, "b"],
                ['.', "."],
                [:IDENTIFIER, "a!"],
                ['()', "()"]]
    assert_equal expected, Lexer.new.tokenize("b.a!()")
    expected = [[:FOR, "for"],
                [:IDENTIFIER, "a"],
                [:IN, "in"],
                [:IDENTIFIER, "b"]]
    assert_equal expected, Lexer.new.tokenize("for a in b")
    expected = [[:FOR, "for"],
                [:IDENTIFIER, "a"],
                [',', ", "],
                [:IDENTIFIER, "b"],
                [:IN, "in"],
                [:IDENTIFIER, "c"]]
    assert_equal expected, Lexer.new.tokenize("for a, b in c")
    expected = [[:IDENTIFIER, "from"], ['( ', "( "],
                [:IDENTIFIER, "in"], [':', ": "],
                [:INTEGER, 0],
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
      [:IDENTIFIER, "a"], [:IN, "in"],
      [:IDENTIFIER, "b"],
      [:BLOCKSTART, 1],
        [:NONE, "none"],
      [:BLOCKEND, 1], [:NEWLINE, "\n"]
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
