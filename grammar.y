class Parser

token BLOCKSTART BLOCKEND
token METHOD CLASS CONTRACT IS ENUM
token IDENTIFIER FIELD
token IF ELSE UNLESS WHILE LOOP FOR IN SWITCH CASE
token BREAK CONTINUE PASS RETURN TRY HANDLE AS THROW
token NEWLINE
token INTEGER STRING NONETYPE
token TRUE FALSE NONE
token COMMENT

# Based on the C and C++ Operator Precedence Table:
# http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence
prechigh
  left  '.' '#'
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
  | TryHandle                           { result = val[0] }
  | Message                             { result = val[0] }
  | Operation                           { result = val[0] }
  | Define                              { result = val[0] }
  | Return                              { result = val[0] }
  | Array                               { result = val[0] }
  | Hash                                { result = val[0] }
  | GetSymbol                           { result = val[0] }
  | SetSymbol                           { result = val[0] }
  | "(" Expression ")"                  { result = val[1] }
  | Comment                             { result = val[0] }
  ;

  Typename:
    IDENTIFIER                          { result = val[0].value }
  | NONETYPE                            { result = NoneNode.new }
  ;

  Literal:
    INTEGER                             { result = IntegerNode.new(val[0].value) }
  | STRING                              { result = StringNode.new(val[0].value) }
  | PASS                                { result = PassNode.new }
  | TRUE                                { result = TrueNode.new }
  | FALSE                               { result = FalseNode.new }
  | NONE                                { result = NoneNode.new }
  ;

  Message:
    Expression "." IDENTIFIER ArgumentList { result = SendMessageNode.new(val[0], val[2].value, val[3]) }
  | IDENTIFIER ArgumentList             { result = SendMessageNode.new(nil, val[0].value, val[1]) }
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
  | IDENTIFIER ":" Expression           { result = ArgumentNode.new(val[0].value, val[2]) }
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
  | Expression  "#" Expression          { result = SendMessageNode.new(val[0],  "#", [ArgumentNode.new(nil, val[2])]) }
  ;

  Define:
    METHOD Typename IDENTIFIER ParameterList Block { result = DefineMethodNode.new(val[2].value, val[1], val[3], val[4]) }
  | METHOD IDENTIFIER ParameterList Block { result = DefineMethodNode.new(val[1].value, NoneNode.new, val[2], val[3]) }
  | CLASS IDENTIFIER Block              { result = DefineClassNode.new(val[1].value, [], val[2]) }
  | CLASS IDENTIFIER IS Contracts Block { result = DefineClassNode.new(val[1].value, val[3], val[4]) }
  | CONTRACT IDENTIFIER Block           { result = DefineContractNode.new(val[1].value, val[2]) }
  | METHOD Typename IDENTIFIER ParameterList { result = DefineMethodNode.new(val[2].value, val[1], val[3], NoneNode.new) }
  | ENUM IDENTIFIER EnumBlock           { result = EnumerateNode.new(val[1].value, val[2]) }
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
    IDENTIFIER ":" Expression           { result = ParameterNode.new(val[0].value, val[2]) }
  ;

  Contracts:
    Contract                            { result = [val[0]] }
  | Contracts "," Contract              { result = val[0] << val[2] }
  ;

  Contract:
    IDENTIFIER                          { result = CreateIsContractNode(val[0]) }
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
    IDENTIFIER                          { result = SetSymbolNode.new(val[0].value, nil, nil) }
  ;

  Return:
    RETURN Expression                   { result = ReturnNode.new(val[1]) }
  ;

  Array:
    '[' ']'                             { result = ArrayNode.new([]) }
  | '[' ExpressionList ']'              { result = ArrayNode.new(val[1]) }
  | '[' BLOCKSTART ExpressionList BLOCKEND ']' { result = ArrayNode.new(val[2]) }
  ;

  ExpressionList:
    Expression                          { result = [] << val[0] }
  | ExpressionList ',' Expression       { result = val[0] << val[2] }
  ;

  Hash:
    '{' '}'                             { result = HashNode.new([]) }
  | '{' HashEntryList '}'               { result = HashNode.new(val[1]) }
  | '{' BLOCKSTART HashEntryList BLOCKEND '}' { result = HashNode.new(val[2]) }
  ;

  HashEntryList:
    HashEntry                           { result = [] << val[0] }
  | HashEntryList ',' HashEntry         { result = val[0] << val[2] }
  ;

  HashEntry:
    Expression '=>' Expression          { result = HashEntryNode.new(val[0], val[2]) }
  ;

  ConditionalSet:
    IF ConditionBlock                   { result = IfNode.new([val[1]], nil) }
  | IF ConditionBlock ElseBlock         { result = IfNode.new([val[1]], val[2]) }
  | IF ConditionBlock ElseIfBlocks      { result = IfNode.new(val[2].unshift(val[1]), val[3]) }
  | IF ConditionBlock ElseIfBlocks ElseBlock { result = IfNode.new(val[2].unshift(val[1]), val[3]) }
  | UNLESS ConditionBlock               { result = UnlessNode.new(val[1], nil) }
  | UNLESS ConditionBlock ElseBlock     { result = UnlessNode.new(val[1], val[2]) }
  | SWITCH Expression BLOCKSTART CaseBlocks BLOCKEND { result = SwitchNode.new(val[1], val[3]) }
  | SWITCH Expression BLOCKSTART CaseBlocks ElseBlock BLOCKEND { result = SwitchNode.new(val[1], val[3], val[4]) }
  ;

  ElseIfBlocks:
    ElseIfBlock                         { result = [val[0]] }
  | ElseIfBlocks ElseIfBlock            { result = val[0] << val[1] }
  ;

  ElseIfBlock:
    ELSE IF ConditionBlock              { result = val[2] }
  | Comment ELSE IF ConditionBlock      { val[3].comment = val[0]; result = val[3] }
  ;

  ElseBlock:
    ELSE Block                          { result = ConditionBlockNode.new( nil, val[1]) }
  | ELSE Comment Block                  { result = ConditionBlockNode.new( nil, val[2], val[1]) }
  | Comment ELSE Block                  { result = ConditionBlockNode.new( nil, val[2], val[0]) }
  | ELSE ":" Expression                 { result = ConditionBlockNode.new( nil, val[2]) }
  | Comment ELSE ":" Expression         { result = ConditionBlockNode.new( nil, val[3], val[0]) }
  | ELSE ":" Expression Comment         { result = ConditionBlockNode.new( nil, val[2], val[3]) }
  ;

  CaseBlocks:
    CaseBlock                           { result = [val[0]] }
  | CaseBlocks CaseBlock                { result = val[0] << val[1] }
  ;

  CaseBlock:
    CASE ConditionBlock                 { result = val[1] }
  | Comment CASE ConditionBlock         { val[2].comment = val[0]; result = val[2] }
  ;

  ConditionBlock:
    Expression Block                    { result = ConditionBlockNode.new(val[0], val[1]) }
  | Expression Comment Block            { result = ConditionBlockNode.new(val[0], val[2], val[1]) }
  | Expression ":" Expression           { result = ConditionBlockNode.new(val[0], val[2]) }
  | Expression ":" Expression NEWLINE   { result = ConditionBlockNode.new(val[0], val[2]) }
  | Expression ":" Expression Comment   { result = ConditionBlockNode.new(val[0], val[2], val[3]) }
  ;

  Loop:
    FOR IDENTIFIER IN Expression Block  { result = StandardForNode.new(val[3], val[1].value, val[4]) }
  | FOR IDENTIFIER IN Expression Comment Block { result = StandardForNode.new(val[3], val[1].value, val[5], val[4]) }
  | FOR IDENTIFIER ',' IDENTIFIER IN Expression Block  { result = KeyValueForNode.new(val[5], val[1].value, val[3].value, val[6]) }
  | FOR IDENTIFIER ',' IDENTIFIER IN Expression Comment Block { result = KeyValueForNode.new(val[5], val[1].value, val[3].value, val[7], val[6]) }
  | WHILE ConditionBlock                { result = WhileNode.new(val[1]) }
  | LOOP Block                          { result = LoopNode.new(val[1]) }
  | LOOP Comment Block                  { result = LoopNode.new(val[2], val[1]) }
  ;

  FlowControl:
    BREAK                               { result = BreakNode.new }
  | CONTINUE                            { result = ContinueNode.new }
  | THROW Expression                    { result = ThrowNode.new(val[1]) }
  ;

  TryHandle:
    TRY Block HandleBlocks              { result = TryNode.new(nil, val[1], val[2]) }
  | TRY Comment Block HandleBlocks      { result = TryNode.new(val[1], val[2], val[3]) }
  ;

  HandleBlocks:
    HandleBlock                         { result = [val[0]] }
  | HandleBlocks HandleBlock            { result = val[0] << val[1] }
  ;

  HandleBlock:
    HANDLE IDENTIFIER Block             { result = HandleNode.new(val[1].value, nil, nil, val[2]) }
  | HANDLE IDENTIFIER Comment Block     { result = HandleNode.new(val[1].value, nil, val[2], val[3]) }
  | Comment HANDLE IDENTIFIER Block     { result = HandleNode.new(val[2].value, nil, val[0], val[3]) }
  | HANDLE IDENTIFIER AS IDENTIFIER Block { result = HandleNode.new(val[1].value, val[3].value, nil, val[4]) }
  | HANDLE IDENTIFIER AS IDENTIFIER Comment Block { result = HandleNode.new(val[1].value, val[3].value, val[4], val[5]) }
  | Comment HANDLE IDENTIFIER AS IDENTIFIER Block { result = HandleNode.new(val[2].value, val[4].value, val[0], val[5]) }
  | HANDLE AS IDENTIFIER Block          { result = HandleNode.new(nil, val[2].value, nil, val[3]) }
  | HANDLE AS IDENTIFIER Comment Block  { result = HandleNode.new(nil, val[2].value, val[3], val[4]) }
  | Comment HANDLE AS IDENTIFIER Block  { result = HandleNode.new(nil, val[3].value, val[0], val[4]) }
  | HANDLE Block                        { result = HandleNode.new(nil, nil, nil, val[1]) }
  | HANDLE Comment Block                { result = HandleNode.new(nil, nil, val[1], val[2]) }
  | Comment HANDLE Block                { result = HandleNode.new(nil, nil, val[0], val[2]) }
  ;

  GetSymbol:
    IDENTIFIER                          { result = GetSymbolNode.new(val[0].value, nil) }
  | IDENTIFIER FIELD                    { result = GetSymbolNode.new(val[1].value, val[0].value) }
  ;

  SetSymbol:
    IDENTIFIER "=" Expression           { result = SetSymbolNode.new(val[0].value, val[2], nil) }
  | IDENTIFIER FIELD "=" Expression     { result = SetSymbolNode.new(val[1].value, val[3], val[0].value) }
  ;

  Comment:
    COMMENT                             { result = CommentNode.new(val[0].value) }
  ;

  Terminator:
    NEWLINE
  ;

end

---- header
  require "lexer"
  require "nodes"
  require "daisy_error"

def CreateIsContractNode(lexed_chunk)
  IsContractNode.new(lexed_chunk.value, lexed_chunk.source_info)
end

---- inner
  class ParseError < DaisyError
    attr_reader :token
    def initialize(val, t)
      super("parse error on #{t}", val.source_info)
      @token = val.value
    end
  end

  def parse(code, debug=false)
    @tokens = Lexer.new(debug).tokenize(code)
    @yydebug=debug
    do_parse # Kickoff the parsing process
  end

  def next_token
    @tokens.shift
  end

  def on_error(t, val, vstack)
    raise ParseError.new(val, token_to_str(t))
  end

