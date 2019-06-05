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

  def test_get_variable
    assert_equal Nodes.new([GetSymbolNode.new("q")]), Parser.new.parse("q")
  end

  def test_set_variable
    assert_equal Nodes.new([SetSymbolNode.new("asdf", TrueNode.new())]),
      Parser.new.parse("asdf = true")
  end

  def test_message_no_arguments
    assert_equal Nodes.new([SendMessageNode.new(GetSymbolNode.new("variable"), "method", [])]),
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

  def test_message_with_single_unlabeled_expression
    expected = Nodes.new(
      [
        SendMessageNode.new(
          nil, "method", [
            ArgumentNode.new(
              nil, SendMessageNode.new(
                IntegerNode.new( 2 ), "*", [
                  ArgumentNode.new(
                    nil, IntegerNode.new( 3 )
                  )
                ]
              )
            )
          ]
        )
      ]
    )
    assert_equal expected, Parser.new.parse("method( 2 * 3 )")
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
      SendMessageNode.new(GetSymbolNode.new("foo"), "method", [
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

  def test_return_expression
    expected = Nodes.new(
      [
        ReturnNode.new(
          SendMessageNode.new(
            StringNode.new("A"),
            "*",
            [ArgumentNode.new(nil, IntegerNode.new(5))]
          )
        )
      ]
    )
    assert_equal expected, Parser.new.parse('return "A" * 5')
  end

  def test_multiple_returns
    code = <<-CODE
unless true
    return 1
return 2
CODE

    expected = Nodes.new(
      [
        UnlessNode.new(
          TrueNode.new(), Nodes.new(
            [
              ReturnNode.new(IntegerNode.new(1))
            ]
          )
        ),
        ReturnNode.new(IntegerNode.new(2))
      ]
    )
    assert_equal expected, Parser.new.parse(code)
  end

  def test_false
    code = <<-CODE
if false
    return 1
return 2
CODE

    expected = Nodes.new(
      [
        IfNode.new(
          FalseNode.new(), Nodes.new(
            [
              ReturnNode.new(IntegerNode.new(1))
            ]
          )
        ),
        ReturnNode.new(IntegerNode.new(2))
      ]
    )
    assert_equal expected, Parser.new.parse(code)
  end

  def test_parenthesis_expression_ordering
    expected = Nodes.new([
      SendMessageNode.new(
        SendMessageNode.new(GetSymbolNode.new("a"), "+", [
          ArgumentNode.new(nil, GetSymbolNode.new("b"))
        ]), "+",
        [ArgumentNode.new(nil, GetSymbolNode.new("c"))]
      )
    ])
    assert_equal expected, Parser.new.parse("(a + b) + c")
  end

  def test_addition_operator_ordering
    expected = Nodes.new([
      SendMessageNode.new(
        SendMessageNode.new(GetSymbolNode.new("a"), "+", [
          ArgumentNode.new(nil, GetSymbolNode.new("b"))
        ]), "+",
        [ArgumentNode.new(nil, GetSymbolNode.new("c"))]
      )
    ])
    assert_equal expected, Parser.new.parse("a + b + c")
  end

  def test_if_expression
    code = <<-CODE
if n <= 2
    pass

CODE
    expected = Nodes.new([
      IfNode.new(
        SendMessageNode.new(GetSymbolNode.new("n"), "<=", [
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

  def test_define_method_with_arguments
    code = <<-CODE
Function String Greet( name: String, greeting: "Hello" )
    return greeting + " " + name

CODE
    expected = Nodes.new([
      DefineMessageNode.new(
        "Greet",
        "String",
        [ ParameterNode.new("name", nil, "String"),
          ParameterNode.new("greeting", "String", StringNode.new("Hello"))
        ],
        Nodes.new(
          [
            ReturnNode.new(
              SendMessageNode.new(
                SendMessageNode.new(
                  GetSymbolNode.new("greeting"),
                  "+",
                  [ArgumentNode.new(nil, StringNode.new(" "))]
                ),
                "+",
                [ArgumentNode.new(nil, GetSymbolNode.new("name"))]
              )
            )
          ]
        ),
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments_are_ignored
    assert_equal Nodes.new([CommentNode.new("// pass")]),
      Parser.new.parse("// pass")
  end

  def test_none_is_parsed
    assert_equal Nodes.new([NoneNode.new()]),
      Parser.new.parse("none")
  end

  def test_question_and_negation_operators_on_same_variable
    expected = Nodes.new(
      [
        SendMessageNode.new(
          SendMessageNode.new(
            NoneNode.new(),
            "?",
            []
          ),
          "!",
          []
        )
      ]
    )
    assert_equal expected, Parser.new.parse("!none?")
  end

end
