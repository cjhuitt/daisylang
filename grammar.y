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
  | Expressions Expression              { result = val[0] << val[1] }
  | Expressions Terminator Expression   { result = val[0] << val[2] }
  | Expressions Terminator              { result = val[0] }
  | Terminator                          { result = Nodes.new([]) }
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
  | "(" Expression ")"                  { result = val[1] }
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
    "()"                                { result = [] }
  | "( " Arguments " )"                 { result = val[1] }
  ;

  Arguments:
    Argument                            { result = [val[0]] }
  | Arguments "," Argument              { result = val[0] << val[2] }
  ;

  Argument:
    Expression                          { result = ArgumentNode.new(nil, val[0]) }
  | IDENTIFIER ":" Expression           { result = ArgumentNode.new(val[0], val[2]) }
  ;

  # Need to be defined individually for the precedence table to take effect:
  Operation:
    Expression  "+" Expression { result = SendMessageNode.new(val[0],  "+", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "-" Expression { result = SendMessageNode.new(val[0],  "-", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "*" Expression { result = SendMessageNode.new(val[0],  "*", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "/" Expression { result = SendMessageNode.new(val[0],  "/", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "^" Expression { result = SendMessageNode.new(val[0],  "^", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "<" Expression { result = SendMessageNode.new(val[0],  "<", [ArgumentNode.new(nil, val[2])]) }
  | Expression  ">" Expression { result = SendMessageNode.new(val[0],  ">", [ArgumentNode.new(nil, val[2])]) }
  | Expression "||" Expression { result = SendMessageNode.new(val[0], "||", [ArgumentNode.new(nil, val[2])]) }
  | Expression "&&" Expression { result = SendMessageNode.new(val[0], "&&", [ArgumentNode.new(nil, val[2])]) }
  | Expression "<=" Expression { result = SendMessageNode.new(val[0], "<=", [ArgumentNode.new(nil, val[2])]) }
  | Expression ">=" Expression { result = SendMessageNode.new(val[0], ">=", [ArgumentNode.new(nil, val[2])]) }
  | Expression "==" Expression { result = SendMessageNode.new(val[0], "==", [ArgumentNode.new(nil, val[2])]) }
  | Expression "!=" Expression { result = SendMessageNode.new(val[0], "!=", [ArgumentNode.new(nil, val[2])]) }
  ;

  Define:
    FUNCTION Typename IDENTIFIER ParameterList Block { result = DefineMessageNode.new(val[2], val[1], val[3], val[4]) }
  | FUNCTION IDENTIFIER ParameterList Block { result = DefineMessageNode.new(val[1], NoneNode.new, val[2], val[3]) }
  ;

  ParameterList:
    "()"                                { result = [] }
  | "( " Parameters " )"                { result = val[1] }
  ;

  Parameters:
    Parameter                           { result = [val[0]] }
  | Parameters "," Parameter            { result = val[0] << val[2] }
  ;

  Parameter:
    IDENTIFIER ":" INTEGER              { result = ParameterNode.new(val[0], "Integer", IntegerNode.new(val[2])) }
  | IDENTIFIER ":" STRING               { result = ParameterNode.new(val[0], "String", StringNode.new(val[2])) }
  | IDENTIFIER ":" GetVariable          { result = ParameterNode.new(val[0], nil, val[2]) }
  | IDENTIFIER ":" IDENTIFIER           { result = ParameterNode.new(val[0], val[2], nil) }
  ;

  Block:
    BLOCKSTART Expressions BLOCKEND { result = val[1] }
  ;

  Return:
    RETURN Expression                   { result = ReturnNode.new(val[1]) }
  ;

  If:
    IF Expression Block                 { result = IfNode.new(val[1], val[2]) }
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

