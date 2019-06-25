class LexedChunk < Struct.new(:value, :line, :col)
  def initialize(value, line=1, col=1)
    super(value, line, col)
  end
end

class Lexer
  def initialize(debug=false)
    @string_accumulator = nil
    @debug = debug
    @line_no = 0
  end

  def tokenize(code)
    blocklevel = 0
    tokens = []
    code.lines.each do |line|
      @line_no += 1
      debug_out("Tokenizing line ##{@line_no} >>#{line}<<")
      if indent = line[/\A( +)/, 1]
        blocks = indent.size / 4
        if blocks == blocklevel + 1
          tokens.pop if tokens.last && tokens.last.first == :NEWLINE
          tokens << [:BLOCKSTART, LexedChunk.new(blocks, @line_no)]
          blocklevel = blocks
        else blocks < blocklevel
          tokens.pop if tokens.last && tokens.last.first == :NEWLINE
          while blocks < blocklevel
            tokens << [:BLOCKEND, LexedChunk.new(blocklevel, @line_no)]
            blocklevel -= 1
          end
        end
        line.delete_prefix!("    " * blocklevel)
      elsif 0 < blocklevel
        tokens.pop if tokens.last && tokens.last.first == :NEWLINE
        while 0 < blocklevel
          tokens << [:BLOCKEND, LexedChunk.new(blocklevel, @line_no)]
          blocklevel -= 1
        end
      end if @string_accumulator.nil?
      tokens += tokenize_line(line)
    end
    tokens
  end

  private
    KEYWORDS = [
      "if", "else", "unless", "while", "loop", "switch", "case",
      "break", "continue", "pass", "return",
      "true", "false", "none"
    ]

    def tokenize_line(line)
      tokens = []
      i = 0

      unless @string_accumulator.nil?
        if str = line[/\A([^"]*)"/, 1]
          i += str.size + 1
          @string_accumulator += str;
          debug_out("Extracted \"#{@string_accumulator}\" (String)")
          tokens << [:STRING, LexedChunk.new(@string_accumulator, @string_start_line_no)]
          @string_accumulator = nil
        else
          @string_accumulator += line
          return tokens
        end
      end

      while i < line.size
        sub = line[i..-1]
        debug_out("Checking partial >>#{sub}<<")
        if "//" == sub[0..1]
          tokens << [:COMMENT, LexedChunk.new(sub, @line_no)]
          break
        elsif integer = sub[/\A(\d+)/, 1]
          tokens << [:INTEGER, LexedChunk.new(integer.to_i, @line_no)]
          i += integer.size
          debug_out("Extracted #{integer} (Integer)")
        elsif str = sub[/\A"([^"]*)"/, 1]
          tokens << [:STRING, LexedChunk.new(str, @line_no)]
          i += str.size + 2
          debug_out("Extracted \"#{str}\" (String)")
        elsif str = sub[/\A"([^"]*)/, 1]
          @string_start_line_no = @line_no
          @string_accumulator = str
          i += str.size + 2
        elsif sub.start_with? "Method: "
          tokens << [:METHOD, LexedChunk.new("Method:", @line_no)]
          debug_out("Extracted Method: (Definition)")
          i += "Method: ".size
        elsif sub.start_with? "Class: "
          tokens << [:CLASS, LexedChunk.new("Class:", @line_no)]
          debug_out("Extracted Class: (Definition)")
          i += "Class: ".size
        elsif sub.start_with? "Contract: "
          tokens << [:CONTRACT, LexedChunk.new("Contract:", @line_no)]
          debug_out("Extracted Contract: (Definition)")
          i += "Contract: ".size
        elsif sub.start_with? "Enumerate: "
          tokens << [:ENUM, LexedChunk.new("Enumerate:", @line_no)]
          debug_out("Extracted Enumerate: (Definition)")
          i += "Enumerate: ".size
        elsif sub.start_with? "is "
          tokens << [:IS, LexedChunk.new("is", @line_no)]
          debug_out("Extracted is (Keyword)")
          i += "is ".size
        elsif identifier = sub[/\A(\w+\.\w+)(\)|\s|$)/, 1]
          id = sub[/\A(\w+)/, 1]
          tokens << [:IDENTIFIER, LexedChunk.new(id, @line_no)]
          debug_out("Extracted #{id} (Identifier)")
          i += id.size

          i += 1 # period

          id = sub[/\A(\w+)\.(\w+)/, 2]
          tokens << [:FIELD, LexedChunk.new(id, @line_no)]
          debug_out("Extracted #{id} (Field)")
          i += id.size
        elsif identifier = sub[/\Afor (\w+) in/, 1]
          tokens << [:FOR, LexedChunk.new("for", @line_no)]
          debug_out("Extracted for (Keyword)")
          i += 4 # "for "

          tokens << [:IDENTIFIER, LexedChunk.new(identifier, @line_no)]
          debug_out("Extracted #{identifier} (Identifier)")
          i += identifier.size

          tokens << [:IN, LexedChunk.new("in", @line_no)]
          debug_out("Extracted in (Keyword)")
          i += 3 # "in "
        elsif identifiers = sub[/\Afor (\w+, \w+) in/, 1]
          tokens << [:FOR, LexedChunk.new("for", @line_no)]
          debug_out("Extracted for (Keyword)")
          i += 4 # "for "

          key = identifiers.split(", ").first
          tokens << [:IDENTIFIER, LexedChunk.new(key, @line_no)]
          debug_out("Extracted #{key} (Identifier)")

          tokens << [',', LexedChunk.new(", ", @line_no)]
          debug_out("Extracted , (Operator)")

          val = identifiers.split(", ").last
          tokens << [:IDENTIFIER, LexedChunk.new(val, @line_no)]
          debug_out("Extracted #{val} (Identifier)")
          i += identifiers.size

          tokens << [:IN, LexedChunk.new("in", @line_no)]
          debug_out("Extracted in (Keyword)")
          i += 3 # "in "
        elsif identifier = sub[/\A(\w+[\?!])\(/, 1]
          tokens << [:IDENTIFIER, LexedChunk.new(identifier, @line_no)]
          debug_out("Extracted #{identifier} (Identifier)")
          i += identifier.size
        elsif identifier = sub[/\A(\w+)/, 1]
          if KEYWORDS.include? identifier
            tokens << [identifier.upcase.to_sym, LexedChunk.new(identifier, @line_no)]
            debug_out("Extracted #{identifier} (Keyword)")
          else
            tokens << [:IDENTIFIER, LexedChunk.new(identifier, @line_no)]
            debug_out("Extracted #{identifier} (Identifier)")
          end
          i += identifier.size
        elsif "()" == sub[0..1]
          tokens << ["()", LexedChunk.new("()", @line_no)]
          i += 2
          debug_out("Extracted () (Operator)")
        elsif "( " == sub[0..1]
          tokens << ["( ", LexedChunk.new("( ", @line_no)]
          i += 2
          debug_out("Extracted ( (Operator)")
        elsif " )" == sub[0..1]
          tokens << [" )", LexedChunk.new(" )", @line_no)]
          i += 2
          debug_out("Extracted ) (Operator)")
        elsif op = sub[/\A( [=+-\/^*<>] )/, 1]
          tok = op.strip
          tokens << [tok, LexedChunk.new(op, @line_no)]
          i += op.size
          debug_out("Extracted #{tok} (Operator)")
        elsif op = sub[/\A([:,])[ \n]/, 1]
          tok = op.strip
          tokens << [tok, LexedChunk.new(op + " ", @line_no)]
          i += op.size + 1
          debug_out("Extracted #{tok} (Operator)")
        elsif op = sub[/\A(&&|\|\|)/, 1]
          tokens << [op, LexedChunk.new(op, @line_no)]
          i += 2
          debug_out("Extracted #{op} (Operator)")
        elsif op = sub[/\A(==|!=|<=|>=|=>)/, 1]
          tokens << [op, LexedChunk.new(op, @line_no)]
          i += 2
          debug_out("Extracted #{op} (Operator)")
        elsif op = sub[/\A([().?!\[\]{}#])/, 1]
          tokens << [op, LexedChunk.new(op, @line_no)]
          i += op.size
          debug_out("Extracted #{op} (Operator)")
        elsif space = sub[/\A(\s*\n)/m, 1]
          tokens << [:NEWLINE, LexedChunk.new("\n", @line_no)]
          i += space.size
          debug_out("Extracted newline")
        elsif space = sub[/\A(\s+)/, 1]
          i += space.size
          debug_out("Extracted whitespace")
        else
          raise "Unlexable chunk: >>#{sub}<<"
        end
      end

      tokens
    end

    def debug_out(message)
      puts message if @debug
    end
end
