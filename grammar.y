class Parser

token BLOCKSTART BLOCKEND
token METHOD CLASS CONTRACT IS ENUM
token IDENTIFIER FIELD
token INTEGER STRING
token IF UNLESS RETURN FOR IN WHILE ELSE BREAK LOOP CONTINUE
token NEWLINE
token NONETYPE
token PASS TRUE FALSE NONE
token COMMENT

# Based on the C and C++ Operator Precedence Table:
# http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence
prechigh
  left  '.'
  left  '?'
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
  | Expressions Terminator              { result = val[0] }
  | Terminator                          { result = Nodes.new([]) }
  ;

  # Every type of expression supported by our language is defined here.
  Expression:
    Literal                             { result = val[0] }
  | ConditionalSet                      { result = val[0] }
  | Loop                                { result = val[0] }
  | FlowControl                         { result = val[0] }
  | Message                             { result = val[0] }
  | Operation                           { result = val[0] }
  | Define                              { result = val[0] }
  | Return                              { result = val[0] }
  | Array                               { result = val[0] }
  | GetSymbol                           { result = val[0] }
  | SetSymbol                           { result = val[0] }
  | "(" Expression ")"                  { result = val[1] }
  | Comment                             { result = val[0] }
  ;

  Typename:
    IDENTIFIER                          { result = val[0] }
  | NONETYPE                            { result = NoneNode.new }
  ;

  Literal:
    INTEGER                             { result = IntegerNode.new(val[0]) }
  | STRING                              { result = StringNode.new(val[0]) }
  | PASS                                { result = PassNode.new }
  | TRUE                                { result = TrueNode.new }
  | FALSE                               { result = FalseNode.new }
  | NONE                                { result = NoneNode.new }
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
    Expression  "+" Expression          { result = SendMessageNode.new(val[0],  "+", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "-" Expression          { result = SendMessageNode.new(val[0],  "-", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "*" Expression          { result = SendMessageNode.new(val[0],  "*", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "/" Expression          { result = SendMessageNode.new(val[0],  "/", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "^" Expression          { result = SendMessageNode.new(val[0],  "^", [ArgumentNode.new(nil, val[2])]) }
  | Expression  "<" Expression          { result = SendMessageNode.new(val[0],  "<", [ArgumentNode.new(nil, val[2])]) }
  | Expression  ">" Expression          { result = SendMessageNode.new(val[0],  ">", [ArgumentNode.new(nil, val[2])]) }
  | Expression "||" Expression          { result = SendMessageNode.new(val[0], "||", [ArgumentNode.new(nil, val[2])]) }
  | Expression "&&" Expression          { result = SendMessageNode.new(val[0], "&&", [ArgumentNode.new(nil, val[2])]) }
  | Expression "<=" Expression          { result = SendMessageNode.new(val[0], "<=", [ArgumentNode.new(nil, val[2])]) }
  | Expression ">=" Expression          { result = SendMessageNode.new(val[0], ">=", [ArgumentNode.new(nil, val[2])]) }
  | Expression "==" Expression          { result = SendMessageNode.new(val[0], "==", [ArgumentNode.new(nil, val[2])]) }
  | Expression "!=" Expression          { result = SendMessageNode.new(val[0], "!=", [ArgumentNode.new(nil, val[2])]) }
  |             "!" Expression          { result = SendMessageNode.new(val[1],  "!", []) }
  | Expression  "?"                     { result = SendMessageNode.new(val[0],  "?", []) }
  ;

  Define:
    METHOD Typename IDENTIFIER ParameterList Block { result = DefineMessageNode.new(val[2], val[1], val[3], val[4]) }
  | METHOD IDENTIFIER ParameterList Block { result = DefineMessageNode.new(val[1], NoneNode.new, val[2], val[3]) }
  | CLASS IDENTIFIER Block              { result = DefineClassNode.new(val[1], [], val[2]) }
  | CLASS IDENTIFIER IS Contracts Block { result = DefineClassNode.new(val[1], val[3], val[4]) }
  | CONTRACT IDENTIFIER Block           { result = DefineContractNode.new(val[1], val[2]) }
  | METHOD Typename IDENTIFIER ParameterList { result = DefineMessageNode.new(val[2], val[1], val[3], NoneNode.new) }
  | ENUM IDENTIFIER EnumBlock           { result = EnumerateNode.new(val[1], val[2]) }
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
  | IDENTIFIER ":" IDENTIFIER           { result = ParameterNode.new(val[0], nil, val[2]) }
  ;

  Contracts:
    Contract                            { result = [val[0]] }
  | Contracts "," Contract              { result = val[0] << val[2] }
  ;

  Contract:
    IDENTIFIER                          { result = val[0] }
  ;

  Block:
    BLOCKSTART Expressions BLOCKEND     { result = val[1] }
  ;

  EnumBlock:
    BLOCKSTART EnumDefinitions BLOCKEND { result = val[1] }
  ;

  EnumDefinitions:
    EnumDefinition                      { result = [val[0]] }
  | EnumDefinitions EnumDefinition      { result = val[0] << val[1] }
  ;

  EnumDefinition:
    IDENTIFIER                          { result = SetSymbolNode.new(val[0], nil, nil) }
  ;

  Return:
    RETURN Expression                   { result = ReturnNode.new(val[1]) }
  ;

  Array:
    '[' ']'                             { result = ArrayNode.new([]) }
  | '[' ExpressionList ']'              { result = ArrayNode.new(val[1]) }
  ;

  ExpressionList:
    Expression                          { result = [] << val[0] }
  | ExpressionList ',' Expression       { result = val[0] << val[2] }
  ;

  ConditionalSet:
    IF ConditionBlock                   { result = IfNode.new([val[1]], nil) }
  | IF ConditionBlock ElseBlock         { result = IfNode.new([val[1]], val[2]) }
  | IF ConditionBlock ElseIfBlocks      { result = IfNode.new(val[2].unshift(val[1]), val[3]) }
  | IF ConditionBlock ElseIfBlocks ElseBlock { result = IfNode.new(val[2].unshift(val[1]), val[3]) }
  | UNLESS ConditionBlock               { result = UnlessNode.new(val[1], nil) }
  | UNLESS ConditionBlock ElseBlock     { result = UnlessNode.new(val[1], val[2]) }
  ;

  ElseIfBlocks:
    ElseIfBlock                         { result = [val[0]] }
  | ElseIfBlocks ElseIfBlock            { result = val[0] << val[1] }
  ;

  ElseIfBlock:
    ELSE IF ConditionBlock              { result = val[2] }
  ;

  ElseBlock:
    ELSE Block                          { result = ConditionBlockNode.new( nil, val[1]) }
  | ELSE Comment Block                  { result = ConditionBlockNode.new( nil, val[2], val[1]) }
  ;

  ConditionBlock:
    Expression Block                    { result = ConditionBlockNode.new(val[0], val[1]) }
  | Expression Comment Block            { result = ConditionBlockNode.new(val[0], val[2], val[1]) }
  ;

  Loop:
    FOR IDENTIFIER IN Expression Block  { result = ForNode.new(val[3], val[1], val[4]) }
  | FOR IDENTIFIER IN Expression Comment Block { result = ForNode.new(val[3], val[1], val[5], val[4]) }
  | WHILE ConditionBlock                { result = WhileNode.new(val[1]) }
  | LOOP Block                          { result = LoopNode.new(val[1]) }
  | LOOP Comment Block                  { result = LoopNode.new(val[2], val[1]) }
  ;

  FlowControl:
    BREAK                               { result = BreakNode.new }
  | CONTINUE                            { result = ContinueNode.new }
  ;

  GetSymbol:
    IDENTIFIER                          { result = GetSymbolNode.new(val[0], nil) }
  | IDENTIFIER FIELD                    { result = GetSymbolNode.new(val[1], val[0]) }
  ;

  SetSymbol:
    IDENTIFIER "=" Expression           { result = SetSymbolNode.new(val[0], val[2], nil) }
  | IDENTIFIER FIELD "=" Expression     { result = SetSymbolNode.new(val[1], val[3], val[0]) }
  ;

  Comment:
    COMMENT                             { result = CommentNode.new(val[0]) }
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

