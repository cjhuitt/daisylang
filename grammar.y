class Parser

# Based on the C and C++ Operator Precedence Table:
# http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence
prechigh
  left  '.'
  right '!'
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
    /* nothing */                      { result = Nodes.new([]) }
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

