class Parser

token BLOCKEND
token BLOCKSTART
token FUNCTION
token IDENTIFIER
token INTEGER
token IF
token NEWLINE
token NONETYPE
token PASS
token RETURN
token STRING
token WHITESPACE

# Based on the C and C++ Operator Precedence Table:
# http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence
prechigh
  left  '.'
  right '!'
  left  '^'
  left  '*' '/'
  left  '+' '-'
  left  '>' '>=' '<' '<='
  left  '==' '!='
  left  '&&'
  left  '||'
  right '='
  left  ','
preclow

rule
  Program:
    /* nothing */                       { result = Nodes.new([]) }
  | Expressions                         { result = val[0] }
  ;

  Expressions:
    Expression                          { result = Nodes.new([]) << val[0] }
  | Expressions Terminator Expression   { result = val[0] << val[2] }
  | Expressions Terminator              { result = val[0] }
  ;

  # Every type of expression supported by our language is defined here.
  Expression:
    Literal                             { result = val[0] }
  | If                                  { result = val[0] }
  | Message                             { result = val[0] }
  | Operation                           { result = val[0] }
  | Define                              { result = val[0] }
  | Return                              { result = val[0] }
  | GetVariable                         { result = val[0] }
  | Terminator                          { result = nil }
  ;

  Typename:
    IDENTIFIER                          { result = val[0] }
  | NONETYPE                            { result = NoneNode.new }
  ;

  Literal:
    INTEGER                             { result = IntegerNode.new(val[0]) }
  | STRING                              { result = StringNode.new(val[0]) }
  | PASS                                { result = PassNode.new }
  ;

  Message:
    Expression "." IDENTIFIER ArgumentList { result = SendMessageNode.new(val[0], val[2], val[3]) }
  | IDENTIFIER ArgumentList             { result = SendMessageNode.new(nil, val[0], val[1]) }
  ;

  ArgumentList:
    "(" ")" { result = [] }
  | "(" WHITESPACE Arguments WHITESPACE ")" { result = val[2] }
  ;

  Arguments:
    Argument                            { result = [val[0]] }
  | Arguments "," WHITESPACE Argument   { result = val[0] << val[3] }
  ;

  Argument:
    Literal                             { result = ArgumentNode.new(nil, val[0]) }
  | IDENTIFIER ":" WHITESPACE Literal   { result = ArgumentNode.new(val[0], val[3]) }
  ;

  # Need to be defined individually for the precedence table to take effect:
  Operation:
    Expression WHITESPACE "+"  WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "-"  WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "*"  WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "/"  WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "^"  WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "<"  WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE ">"  WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "||" WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "&&" WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "<=" WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE ">=" WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "==" WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  | Expression WHITESPACE "!=" WHITESPACE Expression { result = SendMessageNode.new(val[0], val[2], [ArgumentNode.new(nil, val[4])]) }
  ;

  Define:
    FUNCTION WHITESPACE Typename WHITESPACE IDENTIFIER ParameterList Block { result = DefineMessageNode.new(val[4], val[2], val[5], val[6]) }
  | FUNCTION WHITESPACE IDENTIFIER ParameterList Block { result = DefineMessageNode.new(val[2], NoneNode.new, val[3], val[4]) }
  ;

  ParameterList:
    "(" ")"                             { result = [] }
  ;

  Block:
    NEWLINE BLOCKSTART Expressions BLOCKEND { result = val[2] }
  ;

  Return:
    RETURN WHITESPACE Expression        { result = ReturnNode.new(val[2]) }
  ;

  If:
    IF WHITESPACE Expression Block { result = IfNode.new(val[2], val[3]) }
  ;

  GetVariable:
    IDENTIFIER                          { result = GetVariableNode.new(val[0]) }
  ;

  Terminator:
    NEWLINE
  ;

end

---- header
  require "lexer"
  require "nodes"

---- inner
  def parse(code, debug=false)
    @tokens = Lexer.new(debug).tokenize(code)
    @yydebug=debug
    do_parse # Kickoff the parsing process
  end

  def next_token
    @tokens.shift
  end

