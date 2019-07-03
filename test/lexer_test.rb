require "test_helper"
require "lexer"

class LexerTest < Test::Unit::TestCase
  def test_empty
    assert_equal [], Lexer.new.tokenize("")
  end

  def test_int
    expected = [[:INTEGER, LexedChunk.new(1, "1", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("1")
  end

  def test_string
    expected = [[:STRING, LexedChunk.new("Greetings  fools", '"Greetings  fools"', 1, 1)]]
    assert_equal expected, Lexer.new.tokenize('"Greetings  fools"')
  end

  def test_string_with_linewraps
    code = "\"Greetings\n\n    fools\""
    expected = [[:STRING, LexedChunk.new("Greetings\n\n    fools", "    fools\"", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_empty_line
    expected = [[:NEWLINE, LexedChunk.new("\n", "\n", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("\n")
  end

  def test_int_with_newline
    expected = [
      [:INTEGER, LexedChunk.new(5, "5\n", 1, 1)],
      [:NEWLINE, LexedChunk.new("\n", "5\n", 1, 2)]
    ]
    assert_equal expected, Lexer.new.tokenize("5\n")
  end

  def test_ignores_whitespace_before_newlines
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", "a    \t \n", 1, 1)],
      [:NEWLINE, LexedChunk.new("\n", "a    \t \n", 1, 8)]
    ]
    assert_equal expected, Lexer.new.tokenize("a    \t \n")
  end

  def test_recognizes_keywords
    expected = [[:IF, LexedChunk.new("if", "if", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("if")
    expected = [[:ELSE, LexedChunk.new("else", "else", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("else")
    expected = [[:UNLESS, LexedChunk.new("unless", "unless", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("unless")
    expected = [[:WHILE, LexedChunk.new("while", "while", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("while")
    expected = [[:LOOP, LexedChunk.new("loop", "loop", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("loop")
    expected = [[:SWITCH, LexedChunk.new("switch", "switch", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("switch")
    expected = [[:CASE, LexedChunk.new("case", "case", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("case")

    expected = [[:BREAK, LexedChunk.new("break", "break", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("break")
    expected = [[:CONTINUE, LexedChunk.new("continue", "continue", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("continue")
    expected = [[:PASS, LexedChunk.new("pass", "pass", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("pass")
    expected = [[:RETURN, LexedChunk.new("return", "return", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("return")
    expected = [[:TRY, LexedChunk.new("try", "try", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("try")
    expected = [[:HANDLE, LexedChunk.new("handle", "handle", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("handle")
    expected = [[:AS, LexedChunk.new("as", "as ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("as ")

    expected = [[:TRUE, LexedChunk.new("true", "true", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("true")
    expected = [[:FALSE, LexedChunk.new("false", "false", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("false")
    expected = [[:NONE, LexedChunk.new("none", "none", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("none")
  end

  def test_recognizes_identifiers
    expected = [[:IDENTIFIER, LexedChunk.new("Integer", "Integer", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Integer")
    expected = [[:IDENTIFIER, LexedChunk.new("None", "None", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("None")
    expected = [[:IDENTIFIER, LexedChunk.new("Method", "Method", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Method")
    expected = [[:METHOD, LexedChunk.new("Method:", "Method: ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Method: ")
    expected = [[:IDENTIFIER, LexedChunk.new("Class", "Class", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Class")
    expected = [[:CLASS, LexedChunk.new("Class:", "Class: ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Class: ")
    expected = [[:CONTRACT, LexedChunk.new("Contract:", "Contract: ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Contract: ")
    expected = [[:IDENTIFIER, LexedChunk.new("Contract", "Contract", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Contract")
    expected = [[:ENUM, LexedChunk.new("Enumerate:", "Enumerate: ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("Enumerate: ")
  end

  def test_recognizes_simple_operators
    expected = [['=', LexedChunk.new(" = ", " = ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(" = ")
    expected = [['+', LexedChunk.new(" + ", " + ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(" + ")
    expected = [['-', LexedChunk.new(" - ", " - ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(" - ")
    expected = [['*', LexedChunk.new(" * ", " * ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(" * ")
    expected = [['/', LexedChunk.new(" / ", " / ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(" / ")
    expected = [['^', LexedChunk.new(" ^ ", " ^ ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(" ^ ")
    expected = [[':', LexedChunk.new(": ", ": ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(": ")
    expected = [[',', LexedChunk.new(", ", ", ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(", ")
    expected = [[',', LexedChunk.new(", ", ",\n", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(",\n")
    expected = [['( ', LexedChunk.new("( ", "( ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("( ")
    expected = [[' )', LexedChunk.new(" )", " )", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(" )")
    expected = [['(', LexedChunk.new("(", "(", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("(")
    expected = [[')', LexedChunk.new(")", ")", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(")")
    expected = [['?', LexedChunk.new("?", "?", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("?")
    expected = [['!', LexedChunk.new("!", "!", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("!")
    expected = [['[', LexedChunk.new("[", "[", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("[")
    expected = [[']', LexedChunk.new("]", "]", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("]")
    expected = [['{', LexedChunk.new("{", "{", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("{")
    expected = [['}', LexedChunk.new("}", "}", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("}")
    expected = [['#', LexedChunk.new("#", "#", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("#")
  end

  def test_recognizes_multichar_operators
    expected = [['&&', LexedChunk.new("&&", "&&", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("&&")
    expected = [['||', LexedChunk.new("||", "||", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("||")
    expected = [['==', LexedChunk.new("==", "==", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("==")
    expected = [['!=', LexedChunk.new("!=", "!=", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("!=")
    expected = [['>=', LexedChunk.new(">=", ">=", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize(">=")
    expected = [['<=', LexedChunk.new("<=", "<=", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("<=")
    expected = [['=>', LexedChunk.new("=>", "=>", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("=>")
  end

  def test_finds_multiple_tokens_on_a_line
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", "a + b ", 1, 1)],
      ['+', LexedChunk.new(" + ", "a + b ", 1, 2)],
      [:IDENTIFIER, LexedChunk.new("b", "a + b ", 1, 5)]
    ]
    assert_equal expected, Lexer.new.tokenize("a + b ")
  end

  def test_finds_multiple_strings_on_a_line
    expected = [
      [:STRING, LexedChunk.new("a", '"a" + "b"', 1, 1)],
      ['+', LexedChunk.new(" + ", '"a" + "b"', 1, 4)],
      [:STRING, LexedChunk.new("b", '"a" + "b"', 1, 7)]
    ]
    assert_equal expected, Lexer.new.tokenize('"a" + "b"')
  end

  def test_finds_multiple_tokens_without_whitespace
    expected = [
      ['(', LexedChunk.new("(", "(b)", 1, 1)],
      [:IDENTIFIER, LexedChunk.new("b", "(b)", 1, 2)],
      [')', LexedChunk.new(")", "(b)", 1, 3)]
    ]
    assert_equal expected, Lexer.new.tokenize("(b)")
  end

  def test_lexes_block_opening
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", "a\n", 1, 1)],
      [:BLOCKSTART, LexedChunk.new(1, "    ", 2, 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("a\n    ")
  end

  def test_lexes_block_closing
    expected = [
      [:BLOCKSTART, LexedChunk.new(1, "    \n", 1, 1)],
      [:BLOCKEND, LexedChunk.new(1, "(", 2, 1)],
      ['(', LexedChunk.new("(", "(", 2, 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("    \n(")
  end

  def test_method
    code = <<-CODE
Method: Integer Summation( n: Integer )
    return n * (n - 1) / 2

CODE
    expected = [
      [:METHOD, LexedChunk.new("Method:", "Method: Integer Summation( n: Integer )\n", 1, 1)],
          [:IDENTIFIER, LexedChunk.new("Integer", "Method: Integer Summation( n: Integer )\n", 1, 9)],
          [:IDENTIFIER, LexedChunk.new("Summation", "Method: Integer Summation( n: Integer )\n", 1, 17)],
          ['( ', LexedChunk.new("( ", "Method: Integer Summation( n: Integer )\n", 1, 26)],
          [:IDENTIFIER, LexedChunk.new("n", "Method: Integer Summation( n: Integer )\n", 1, 28)],
          [':', LexedChunk.new(": ", "Method: Integer Summation( n: Integer )\n", 1, 29)],
          [:IDENTIFIER, LexedChunk.new("Integer", "Method: Integer Summation( n: Integer )\n", 1, 31)],
          [' )', LexedChunk.new(" )", "Method: Integer Summation( n: Integer )\n", 1, 38)],
        [:BLOCKSTART, LexedChunk.new(1, "    return n * (n - 1) / 2\n", 2, 1)],
          [:RETURN, LexedChunk.new("return", "    return n * (n - 1) / 2\n", 2, 5)],
              [:IDENTIFIER, LexedChunk.new("n", "    return n * (n - 1) / 2\n", 2, 12)],
              ['*', LexedChunk.new(" * ", "    return n * (n - 1) / 2\n", 2, 13)],
              ['(', LexedChunk.new("(", "    return n * (n - 1) / 2\n", 2, 16)],
              [:IDENTIFIER, LexedChunk.new("n", "    return n * (n - 1) / 2\n", 2, 17)],
              ['-', LexedChunk.new(" - ", "    return n * (n - 1) / 2\n", 2, 18)],
              [:INTEGER, LexedChunk.new(1, "    return n * (n - 1) / 2\n", 2, 21)],
              [')', LexedChunk.new(")", "    return n * (n - 1) / 2\n", 2, 22)],
              ['/', LexedChunk.new(" / ", "    return n * (n - 1) / 2\n", 2, 23)],
              [:INTEGER, LexedChunk.new(2, "    return n * (n - 1) / 2\n", 2, 26)],
        [:BLOCKEND, LexedChunk.new(1, "\n", 3, 1)],
        [:NEWLINE, LexedChunk.new("\n", "\n", 3, 1)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_call_print_of_string
    code = <<-CODE
print( "Hello World" )
CODE
    expected = [
      [:IDENTIFIER, LexedChunk.new("print", code, 1, 1)], ['( ', LexedChunk.new("( ", code, 1, 6)],
      [:STRING, LexedChunk.new("Hello World", code, 1, 8)], [' )', LexedChunk.new(" )", code, 1, 21)],
      [:NEWLINE, LexedChunk.new("\n", code, 1, 23)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_call_method_on_variable
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", "a.b()", 1, 1)], ['.', LexedChunk.new(".", "a.b()", 1, 2)], [:IDENTIFIER, LexedChunk.new("b", "a.b()", 1, 3)],
      ['()', LexedChunk.new("()", "a.b()", 1, 4)]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b()")
  end

  def test_member_variable
    expected = [
      [:IDENTIFIER, LexedChunk.new("a", "a.b", 1, 1)],
      [:FIELD, LexedChunk.new("b", "a.b", 1, 3)]
    ]
    assert_equal expected, Lexer.new.tokenize("a.b")
  end

  def test_member_variable_in_subexpression
    expected = [
      ['(', LexedChunk.new("(", "(a.b + a.b)", 1, 1)],
      [:IDENTIFIER, LexedChunk.new("a", "(a.b + a.b)", 1, 2)],
      [:FIELD, LexedChunk.new("b", "(a.b + a.b)", 1, 4)],
      ['+', LexedChunk.new(" + ", "(a.b + a.b)", 1, 5)],
      [:IDENTIFIER, LexedChunk.new("a", "(a.b + a.b)", 1, 8)],
      [:FIELD, LexedChunk.new("b", "(a.b + a.b)", 1, 10)],
      [')', LexedChunk.new(")", "(a.b + a.b)", 1, 11)]
    ]
    assert_equal expected, Lexer.new.tokenize("(a.b + a.b)")
  end

  def test_call_method_with_multiple_parameters
    code = <<-CODE
Greet( name: "Caleb", greeting: "Hey" )
CODE
    expected = [
      [:IDENTIFIER, LexedChunk.new("Greet", code, 1, 1)], ['( ', LexedChunk.new("( ", code, 1, 6)],
      [:IDENTIFIER, LexedChunk.new("name", code, 1, 8)], [':', LexedChunk.new(": ", code, 1, 12)], [:STRING, LexedChunk.new("Caleb", code, 1, 14)], [',', LexedChunk.new(", ", code, 1, 21)],
      [:IDENTIFIER, LexedChunk.new("greeting", code, 1, 23)], [':', LexedChunk.new(": ", code, 1, 31)], [:STRING, LexedChunk.new("Hey", code, 1, 33)],
      [' )', LexedChunk.new(" )", code, 1, 38)], [:NEWLINE, LexedChunk.new("\n", code, 1, 40)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_comment
    expected = [
      [:COMMENT, LexedChunk.new("// true", "// true", 1, 1)]
    ]
    assert_equal expected, Lexer.new.tokenize("// true")
  end

  def test_distinguishes_potentially_ambiguous_portions
    expected = [[:IDENTIFIER, LexedChunk.new("a", "a?", 1, 1)],
                ["?", LexedChunk.new("?", "a?", 1, 2)]]
    assert_equal expected, Lexer.new.tokenize("a?")
    expected = [[:IDENTIFIER, LexedChunk.new("b", "b.a?()", 1, 1)],
                ['.', LexedChunk.new(".", "b.a?()", 1, 2)],
                [:IDENTIFIER, LexedChunk.new("a?", "b.a?()", 1, 3)],
                ['()', LexedChunk.new("()", "b.a?()", 1, 5)]]
    assert_equal expected, Lexer.new.tokenize("b.a?()")
    expected = [[:IDENTIFIER, LexedChunk.new("a?", "a?()", 1, 1)],
                ['()', LexedChunk.new("()", "a?()", 1, 3)]]
    assert_equal expected, Lexer.new.tokenize("a?()")
    expected = [[:IDENTIFIER, LexedChunk.new("a?", "a?( b )", 1, 1)],
                ['( ', LexedChunk.new("( ", "a?( b )", 1, 3)],
                [:IDENTIFIER, LexedChunk.new("b", "a?( b )", 1, 5)],
                [' )', LexedChunk.new(" )", "a?( b )", 1, 6)]]
    assert_equal expected, Lexer.new.tokenize("a?( b )")
    expected = [[:IS, LexedChunk.new("is", "is ", 1, 1)]]
    assert_equal expected, Lexer.new.tokenize("is ")
    expected = [[:IDENTIFIER, LexedChunk.new("is", "is?", 1, 1)],
                ["?", LexedChunk.new("?", "is?", 1, 3)]]
    assert_equal expected, Lexer.new.tokenize("is?")
    expected = [["!", LexedChunk.new("!", "!a", 1, 1)],
                [:IDENTIFIER, LexedChunk.new("a", "!a", 1, 2)]]
    assert_equal expected, Lexer.new.tokenize("!a")
    expected = [[:IDENTIFIER, LexedChunk.new("b", "b.a!()", 1, 1)],
                ['.', LexedChunk.new(".", "b.a!()", 1, 2)],
                [:IDENTIFIER, LexedChunk.new("a!", "b.a!()", 1, 3)],
                ['()', LexedChunk.new("()", "b.a!()", 1, 5)]]
    assert_equal expected, Lexer.new.tokenize("b.a!()")
    expected = [[:FOR, LexedChunk.new("for", "for a in b", 1, 1)],
                [:IDENTIFIER, LexedChunk.new("a", "for a in b", 1, 5)],
                [:IN, LexedChunk.new("in", "for a in b", 1, 7)],
                [:IDENTIFIER, LexedChunk.new("b", "for a in b", 1, 10)]]
    assert_equal expected, Lexer.new.tokenize("for a in b")
    expected = [[:FOR, LexedChunk.new("for", "for a, b in c", 1, 1)],
                [:IDENTIFIER, LexedChunk.new("a", "for a, b in c", 1, 5)],
                [',', LexedChunk.new(", ", "for a, b in c", 1, 6)],
                [:IDENTIFIER, LexedChunk.new("b", "for a, b in c", 1, 8)],
                [:IN, LexedChunk.new("in", "for a, b in c", 1, 10)],
                [:IDENTIFIER, LexedChunk.new("c", "for a, b in c", 1, 13)]]
    assert_equal expected, Lexer.new.tokenize("for a, b in c")
    expected = [[:IDENTIFIER, LexedChunk.new("from", "from( in: 0 )", 1, 1)],
                ['( ', LexedChunk.new("( ", "from( in: 0 )", 1, 5)],
                [:IDENTIFIER, LexedChunk.new("in", "from( in: 0 )", 1, 7)],
                [':', LexedChunk.new(": ", "from( in: 0 )", 1, 9)],
                [:INTEGER, LexedChunk.new(0, "from( in: 0 )", 1, 11)],
                [' )', LexedChunk.new(" )", "from( in: 0 )", 1, 12)]]
    assert_equal expected, Lexer.new.tokenize("from( in: 0 )")
  end

  def test_for_construct
    code = <<-CODE
for a in b
    none

CODE
    expected = [
      [:FOR, LexedChunk.new("for", "for a in b\n", 1, 1)],
      [:IDENTIFIER, LexedChunk.new("a", "for a in b\n", 1, 5)],
      [:IN, LexedChunk.new("in", "for a in b\n", 1, 7)],
      [:IDENTIFIER, LexedChunk.new("b", "for a in b\n", 1, 10)],
      [:BLOCKSTART, LexedChunk.new(1, "    none\n", 2, 1)],
        [:NONE, LexedChunk.new("none", "    none\n", 2, 5)],
      [:BLOCKEND, LexedChunk.new(1, "\n", 3, 1)],
      [:NEWLINE, LexedChunk.new("\n", "\n", 3, 1)]
    ]
    assert_equal expected, Lexer.new.tokenize(code)
  end

  def test_raises_on_unknown
    err = assert_raises Lexer::LexError do
      Lexer.new.tokenize("|")
    end
    assert_true err.message.include?("|")
    assert_equal "|", err.text
    assert_equal 1, err.line
    assert_equal 1, err.col
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
