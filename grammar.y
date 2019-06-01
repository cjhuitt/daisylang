class Parser

token IDENTIFIER
token INTEGER
token NEWLINE
token NONE
token PASS
token RETURN
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
    Expression                          { result = Nodes.new([]) << val.first }
  | Expressions Expression              { result = val[0] << val[1] }
  ;

  # Every type of expression supported by our language is defined here.
  Expression:
    Literal                             { result = val.first }
  | Message                             { result = val.first }
  | Operation                           { result = val.first }
  | Return                              { result = val.first }
  | IDENTIFIER                          { result = val[0] }
  | Terminator                          { result = nil }
  ;

  Literal:
    INTEGER                             { result = IntegerNode.new(val[0]) }
  | NONE                                { result = NoneNode.new }
  | PASS                                { result = PassNode.new }
  ;

  Message:
    Expression "." IDENTIFIER "(" Arguments ")" { result = SendMessageNode.new(val[0], val[2], val[4]) }
  | IDENTIFIER "(" Arguments ")"        { result = SendMessageNode.new(nil, val[0], val[2]) }
  ;

  Arguments:
    /* nothing */                       { result = [] }
  | Argument                            { result = [val[0]] }
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

  Return:
    RETURN WHITESPACE Expression        { result = ReturnNode.new(val[2]) }
  ;

  Terminator:
    NEWLINE
  ;

end

---- header
  require "lexer"
  require "nodes"

---- inner
  def parse(code)
    @tokens = Lexer.new.tokenize(code)
    do_parse # Kickoff the parsing process
  end

  def next_token
    @tokens.shift
  end

