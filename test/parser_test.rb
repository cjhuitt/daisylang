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
    assert_equal Nodes.new([GetSymbolNode.new("q", nil)]), Parser.new.parse("q")
  end

  def test_set_variable
    assert_equal Nodes.new([SetSymbolNode.new("asdf", TrueNode.new(), nil)]),
      Parser.new.parse("asdf = true")
  end

  def test_get_member_variable
    assert_equal Nodes.new([SetSymbolNode.new("a", GetSymbolNode.new("member", "variable"), nil)]),
      Parser.new.parse("a = variable.member")
  end

  def test_set_member_variable
    assert_equal Nodes.new([SetSymbolNode.new("member", TrueNode.new(), "variable")]),
      Parser.new.parse("variable.member = true")
  end

  def test_message_no_arguments
    assert_equal Nodes.new([SendMessageNode.new(GetSymbolNode.new("variable", nil), "method", [])]),
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
      SendMessageNode.new(GetSymbolNode.new("foo", nil), "method", [
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
else
    return 2

CODE
    expected = Nodes.new([
      UnlessNode.new(
        ConditionBlockNode.new(
          TrueNode.new(),
          Nodes.new([
            ReturnNode.new(IntegerNode.new(1))
          ])
        ),
        ConditionBlockNode.new(
          nil,
          Nodes.new([
            ReturnNode.new(IntegerNode.new(2))
          ])
        )
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_false
    code = <<-CODE
if false
    return 1
else
    return 2

CODE
    expected = Nodes.new([
      IfNode.new([
        ConditionBlockNode.new(
          FalseNode.new(),
          Nodes.new([
            ReturnNode.new(IntegerNode.new(1))
          ])
        )],
        ConditionBlockNode.new(
          nil,
          Nodes.new([
            ReturnNode.new(IntegerNode.new(2))
          ])
        )
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_parenthesis_expression_ordering
    expected = Nodes.new([
      SendMessageNode.new(
        SendMessageNode.new(GetSymbolNode.new("a", nil), "+", [
          ArgumentNode.new(nil, GetSymbolNode.new("b", nil))
        ]), "+",
        [ArgumentNode.new(nil, GetSymbolNode.new("c", nil))]
      )
    ])
    assert_equal expected, Parser.new.parse("(a + b) + c")
  end

  def test_addition_operator_ordering
    expected = Nodes.new([
      SendMessageNode.new(
        SendMessageNode.new(GetSymbolNode.new("a", nil), "+", [
          ArgumentNode.new(nil, GetSymbolNode.new("b", nil))
        ]), "+",
        [ArgumentNode.new(nil, GetSymbolNode.new("c", nil))]
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
      IfNode.new([
        ConditionBlockNode.new(
          SendMessageNode.new(GetSymbolNode.new("n", nil), "<=", [
            ArgumentNode.new(nil, IntegerNode.new(2))
          ]),
          Nodes.new([PassNode.new])
        )],
        nil
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_method_with_return_type
    code = <<-CODE
Method: String Greeting()
    return "Hey"

CODE
    expected = Nodes.new([
      DefineMethodNode.new(
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
Method: SayHi()
    pass

CODE
    expected = Nodes.new([
      DefineMethodNode.new(
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
Method: None SayHi()
    pass

CODE
    expected = Nodes.new([
      DefineMethodNode.new(
        "SayHi",
        "None",
        [],
        Nodes.new([PassNode.new])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_method_with_arguments
    code = <<-CODE
Method: String Greet( name: String, greeting: "Hello" )
    return greeting + " " + name

CODE
    expected = Nodes.new([
      DefineMethodNode.new(
        "Greet",
        "String",
        [ ParameterNode.new("name", GetSymbolNode.new("String")),
          ParameterNode.new("greeting", StringNode.new("Hello"))
        ],
        Nodes.new(
          [
            ReturnNode.new(
              SendMessageNode.new(
                SendMessageNode.new(
                  GetSymbolNode.new("greeting", nil),
                  "+",
                  [ArgumentNode.new(nil, StringNode.new(" "))]
                ),
                "+",
                [ArgumentNode.new(nil, GetSymbolNode.new("name", nil))]
              )
            )
          ]
        ),
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_method_with_default_of_another_symbol
    code = <<-CODE
Method: None setVisible( vis: true )
    none

CODE
    expected = Nodes.new([
      DefineMethodNode.new(
        "setVisible",
        "None",
        [ ParameterNode.new("vis", TrueNode.new) ],
        Nodes.new([
          NoneNode.new
        ]),
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments
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

  def test_define_class
    code = <<-CODE
Class: Foo
    a = Integer

CODE
    expected = Nodes.new([
      DefineClassNode.new("Foo",
        [],
        Nodes.new([
          SetSymbolNode.new("a",
            GetSymbolNode.new("Integer", nil),
            nil
          )
        ])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_contract
    code = <<-CODE
Contract: Foo
    Method: None bar()

CODE
    expected = Nodes.new([
      DefineContractNode.new("Foo",
        Nodes.new([
          DefineMethodNode.new(
            "bar",
            "None",
            [],
            NoneNode.new
          )
        ])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_class_with_contracts
    code = <<-CODE
Class: Foo is Functional, Capable
    pass

CODE
    expected = Nodes.new([
      DefineClassNode.new("Foo",
        [ "Functional", "Capable" ],
        Nodes.new([
          PassNode.new
        ])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_empty_array
    expected = Nodes.new([
      ArrayNode.new([
      ])
    ])
    assert_equal expected, Parser.new.parse("[]")
  end

  def test_define_array
    expected = Nodes.new([
      ArrayNode.new([
        IntegerNode.new(1),
        GetSymbolNode.new("b")
      ])
    ])
    assert_equal expected, Parser.new.parse("[1, b]")
  end

  def test_define_array_in_block
    code = <<-CODE
[
    1,
    b
]

CODE
    expected = Nodes.new([
      ArrayNode.new([
        IntegerNode.new(1),
        GetSymbolNode.new("b")
      ])
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_empty_hash
    expected = Nodes.new([
      HashNode.new([
      ])
    ])
    assert_equal expected, Parser.new.parse("{}")
  end

  def test_define_hash
    code = <<-CODE
{ 1 => true, 2 => false }
CODE
    expected = Nodes.new([
      HashNode.new([
        HashEntryNode.new(IntegerNode.new(1), TrueNode.new),
        HashEntryNode.new(IntegerNode.new(2), FalseNode.new)
      ])
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_define_hash_in_block
    code = <<-CODE
{
    1 => true,
    2 => false
}

CODE
    expected = Nodes.new([
      HashNode.new([
        HashEntryNode.new(IntegerNode.new(1), TrueNode.new),
        HashEntryNode.new(IntegerNode.new(2), FalseNode.new)
      ])
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_for_array_loop
    code = <<-CODE
for a in b
    break

CODE
    expected = Nodes.new([
      StandardForNode.new(
        GetSymbolNode.new("b"),
        "a",
        Nodes.new([
          BreakNode.new
        ])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_for_hash_loop
    code = <<-CODE
for a, b in c
    break

CODE
    expected = Nodes.new([
      KeyValueForNode.new(
        GetSymbolNode.new("c"),
        "a", "b",
        Nodes.new([
          BreakNode.new
        ])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_index_into_container
    expected = Nodes.new([
      SendMessageNode.new(
        GetSymbolNode.new("a"),
        "#",
        [ArgumentNode.new(nil, GetSymbolNode.new("b"))]
      )
    ])
    assert_equal expected, Parser.new.parse("a#b")
  end

  def test_while_loop
    code = <<-CODE
while false
    none

CODE
    expected = Nodes.new([
      WhileNode.new(
        ConditionBlockNode.new(
          FalseNode.new,
          Nodes.new([
            NoneNode.new
          ])
        )
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_if_else_blocks
    code = <<-CODE
if a?
    none
else if b?
    none
else if c?
    none
else if d?
    none
else
    none

CODE
    expected = Nodes.new([
      IfNode.new([
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("a", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ])
        ),
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("b", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ])
        ),
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("c", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ])
        ),
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("d", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ])
        )
      ],
      ConditionBlockNode.new(
        nil,
        Nodes.new([ NoneNode.new ])
      ))
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_forever_loop_and_continue
    code = <<-CODE
loop
    if a < 5
        continue
    break

CODE
    expected = Nodes.new([
      LoopNode.new(
        Nodes.new([
          IfNode.new([
            ConditionBlockNode.new(
              SendMessageNode.new(GetSymbolNode.new("a", nil), "<", [
                ArgumentNode.new(nil, IntegerNode.new(5))]),
              Nodes.new([ContinueNode.new])
            )],
            nil
          ),
          BreakNode.new
        ])
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_enumerate
    code = <<-CODE
Enumerate: Lights
    RED
    YELLOW
    GREEN

CODE
    expected = Nodes.new([
      EnumerateNode.new(
        "Lights",
        [ SetSymbolNode.new("RED", nil, nil),
          SetSymbolNode.new("YELLOW", nil, nil),
          SetSymbolNode.new("GREEN", nil, nil),
        ]
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments_on_else_condition_blocks
    code = <<-CODE
if a? // A is valid when foo
    none
else if b? // B is valid when bar
    none
else // Something odd happened
    none

CODE
    expected = Nodes.new([
      IfNode.new([
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("a", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ]),
          CommentNode.new("// A is valid when foo\n" )
        ),
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("b", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ]),
          CommentNode.new("// B is valid when bar\n" )
        )
      ],
      ConditionBlockNode.new(
        nil,
        Nodes.new([ NoneNode.new ]),
        CommentNode.new("// Something odd happened\n")
      ))
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments_on_unless_condition_blocks
    code = <<-CODE
unless a? // A is valid when foo
    none
else // A shouldn't be valid
    none

CODE
    expected = Nodes.new([
      UnlessNode.new(
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("a", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ]),
          CommentNode.new("// A is valid when foo\n" )
        ),
        ConditionBlockNode.new(
          nil,
          Nodes.new([ NoneNode.new ]),
          CommentNode.new("// A shouldn't be valid\n")
        )
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments_on_while_condition
    code = <<-CODE
while true // TODO: should be a forever loop!
    none

CODE
    expected = Nodes.new([
      WhileNode.new(
        ConditionBlockNode.new(
          TrueNode.new,
          Nodes.new([
            NoneNode.new
          ]),
          CommentNode.new("// TODO: should be a forever loop!\n")
        )
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments_on_forever_loop
    code = <<-CODE
loop // Forever
    break

CODE
    expected = Nodes.new([
      LoopNode.new(
        Nodes.new([
          BreakNode.new
        ]),
        CommentNode.new("// Forever\n")
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments_on_for_condition
    code = <<-CODE
for a in b // Check everything
    break

CODE
    expected = Nodes.new([
      StandardForNode.new(
        GetSymbolNode.new("b"),
        "a",
        Nodes.new([
          BreakNode.new
        ]),
        CommentNode.new("// Check everything\n")
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_comments_between_else_condition_blocks
    code = <<-CODE
// A is valid when foo
if a?
    none
// B is valid when bar
else if b?
    none
// Something odd happened
else
    none

CODE
    expected = Nodes.new([
      CommentNode.new("// A is valid when foo\n" ),
      IfNode.new([
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("a", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ])
        ),
        ConditionBlockNode.new(
          SendMessageNode.new(
            GetSymbolNode.new("b", nil),
            "?",
            []
          ),
          Nodes.new([ NoneNode.new ]),
          CommentNode.new("// B is valid when bar\n" )
        )
      ],
      ConditionBlockNode.new(
        nil,
        Nodes.new([ NoneNode.new ]),
        CommentNode.new("// Something odd happened\n")
      ))
    ])
    assert_equal expected, Parser.new.parse(code)
  end

  def test_switch_case_with_comments
    code = <<-CODE
switch a
    case 1: break
    case 2
        continue
    case 5: break // Prime
    case 3 ^ 2 // Trigger on squares
        do_something()
    // Something odd happened
    else
        pass

CODE
    expected = Nodes.new([
      SwitchNode.new(
        GetSymbolNode.new("a"),
        [
          ConditionBlockNode.new(
            IntegerNode.new(1),
            BreakNode.new
          ),
          ConditionBlockNode.new(
            IntegerNode.new(2),
            Nodes.new([ ContinueNode.new ])
          ),
          ConditionBlockNode.new(
            IntegerNode.new(5),
            BreakNode.new,
            CommentNode.new("// Prime\n")
          ),
          ConditionBlockNode.new(
            SendMessageNode.new(
              IntegerNode.new(3),
              "^",
              [ArgumentNode.new(nil, IntegerNode.new(2))]
            ),
            Nodes.new([
              SendMessageNode.new(nil, "do_something", [])
            ]),
            CommentNode.new("// Trigger on squares\n")
          )
        ],
        ConditionBlockNode.new(
          nil,
          Nodes.new([ PassNode.new ]),
          CommentNode.new("// Something odd happened\n")
        )
      )
    ])
    assert_equal expected, Parser.new.parse(code)
  end

end
