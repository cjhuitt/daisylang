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

  def test_variable
    assert_equal Nodes.new([GetVariableNode.new("q")]), Parser.new.parse("q")
  end

  def test_message_no_arguments
    assert_equal Nodes.new([SendMessageNode.new(GetVariableNode.new("variable"), "method", [])]),
      Parser.new.parse("variable.method()")
  end

  def test_message_with_single_unlabeled_argument
    expected = Nodes.new([
      SendMessageNode.new(nil, "method", [
        ArgumentNode.new(nil, IntegerNode.new(13))
      ])
    ])
    assert_equal expected, Parser.new.parse("method( 13 )")
  end

  def test_message_with_single_labeled_argument
    expected = Nodes.new([
      SendMessageNode.new(nil, "method", [
        ArgumentNode.new("foo", IntegerNode.new(13))
      ])
    ])
    assert_equal expected, Parser.new.parse("method( foo: 13 )")
  end

  def test_message_with_multiple_labeled_arguments
    expected = Nodes.new([
      SendMessageNode.new(nil, "method", [
        ArgumentNode.new("foo", IntegerNode.new(13)),
        ArgumentNode.new("bar", IntegerNode.new(42))
      ])
    ])
    assert_equal expected, Parser.new.parse("method( foo: 13, bar: 42 )")
  end

  # Note: this is an error in the language, but the parser should make a
  # representation of it and let the later analysis handle erroring
  def test_message_with_multiple_unlabeled_arguments
    expected = Nodes.new([
      SendMessageNode.new(GetVariableNode.new("foo"), "method", [
        ArgumentNode.new(nil, IntegerNode.new(13)),
        ArgumentNode.new(nil, IntegerNode.new(42))
      ])
    ])
    assert_equal expected, Parser.new.parse("foo.method( 13, 42 )")
  end

  def test_call_print_of_string
    code = <<-CODE
print( "Hello World" )
CODE
    expected = Nodes.new([
      SendMessageNode.new(nil, "print", [
        ArgumentNode.new(nil, StringNode.new("Hello World"))
      ])
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_pass
    assert_equal Nodes.new([PassNode.new]), Parser.new.parse("pass")
  end

  def test_return
    assert_equal Nodes.new([ReturnNode.new(IntegerNode.new(9))]),
      Parser.new.parse("return 9")
  end

  def test_parenthesis_expression_ordering
    expected = Nodes.new([
      SendMessageNode.new(
        SendMessageNode.new(GetVariableNode.new("a"), "+", [
          ArgumentNode.new(nil, GetVariableNode.new("b"))
        ]), "+",
        [ArgumentNode.new(nil, GetVariableNode.new("c"))]
      )
    ])
    assert_equal expected, Parser.new.parse("(a + b) + c")
  end

  def test_addition_operator_ordering
    expected = Nodes.new([
      SendMessageNode.new(
        SendMessageNode.new(GetVariableNode.new("a"), "+", [
          ArgumentNode.new(nil, GetVariableNode.new("b"))
        ]), "+",
        [ArgumentNode.new(nil, GetVariableNode.new("c"))]
      )
    ])
    assert_equal expected, Parser.new.parse("a + b + c")
  end

  def test_addtion_operator_ordering
    expected = Nodes.new([
      SendMessageNode.new(
        SendMessageNode.new(GetVariableNode.new("a"), "+", [
          ArgumentNode.new(nil, GetVariableNode.new("b"))
        ]), "+",
        [ArgumentNode.new(nil, GetVariableNode.new("c"))]
      )
    ])
    assert_equal expected, Parser.new.parse("(a + b) + c")
  end

  def test_if_expression
    code = <<-CODE
if n <= 2
    pass

CODE
    expected = Nodes.new([
      IfNode.new(
        SendMessageNode.new(GetVariableNode.new("n"), "<=", [
          ArgumentNode.new(nil, IntegerNode.new(2))
        ]),
        Nodes.new([PassNode.new])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_method_with_return_type
    code = <<-CODE
Function String Greeting()
    return "Hey"

CODE
    expected = Nodes.new([
      DefineMessageNode.new(
        "Greeting",
        "String",
        [],
        Nodes.new([ReturnNode.new(StringNode.new("Hey"))])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_simple_method_no_return_type
    code = <<-CODE
Function SayHi()
    pass

CODE
    expected = Nodes.new([
      DefineMessageNode.new(
        "SayHi",
        NoneNode.new,
        [],
        Nodes.new([PassNode.new])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_simple_method
    code = <<-CODE
Function None SayHi()
    pass

CODE
    expected = Nodes.new([
      DefineMessageNode.new(
        "SayHi",
        NoneNode.new,
        [],
        Nodes.new([PassNode.new])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

end
