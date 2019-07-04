require "daisy_error"

class LexedChunk < Struct.new(:value, :source_info)
  def initialize(value, text, line=1, col=1)
    super(value, SourceInfo.new(text, line, col))
  end
end

class Lexer
  class LexError < DaisyError
    def initialize(text, part, line, col)
      super("Unlexable chunk \"#{part}\"", SourceInfo.new(text, line, col))
    end
  end

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
          tokens << [:BLOCKSTART, LexedChunk.new(blocks, line, @line_no)]
          blocklevel = blocks
        else blocks < blocklevel
          tokens.pop if tokens.last && tokens.last.first == :NEWLINE
          while blocks < blocklevel
            tokens << [:BLOCKEND, LexedChunk.new(blocklevel, line, @line_no)]
            blocklevel -= 1
          end
        end
      elsif 0 < blocklevel
        tokens.pop if tokens.last && tokens.last.first == :NEWLINE
        while 0 < blocklevel
          tokens << [:BLOCKEND, LexedChunk.new(blocklevel, line, @line_no)]
          blocklevel -= 1
        end
      end if @string_accumulator.nil?
      tokens += tokenize_line(line, (blocklevel * 4) + 1)
    end
    tokens
  end

  private
    KEYWORDS = [
      "if", "else", "unless", "while", "loop", "switch", "case",
      "break", "continue", "pass", "return", "try", "handle", "throw",
      "true", "false", "none"
    ]

    def tokenize_line(line, initial_col)
      tokens = []
      i = 0

      unless @string_accumulator.nil?
        if str = line[/\A([^"]*)"/, 1]
          @string_accumulator += str;
          debug_out("Extracted \"#{@string_accumulator}\" (String)")
          tokens << [:STRING, LexedChunk.new(@string_accumulator, line, @string_start_line, @string_start_col)]
          @string_accumulator = nil
          i += str.size + 1
        else
          @string_accumulator += line
          return tokens
        end
      end

      while i < line.size
        sub = line[i..-1]
        debug_out("Checking partial >>#{sub}<<")
        if "//" == sub[0..1]
          tokens << [:COMMENT, LexedChunk.new(sub, line, @line_no, i + 1)]
          break
        elsif integer = sub[/\A(\d+)/, 1]
          tokens << [:INTEGER, LexedChunk.new(integer.to_i, line, @line_no, i + 1)]
          i += integer.size
          debug_out("Extracted #{integer} (Integer)")
        elsif str = sub[/\A"([^"]*)"/, 1]
          tokens << [:STRING, LexedChunk.new(str, line, @line_no, i + 1)]
          i += str.size + 2
          debug_out("Extracted \"#{str}\" (String)")
        elsif str = sub[/\A"([^"]*)/, 1]
          @string_start_line = @line_no
          @string_start_col = i + 1
          @string_accumulator = str
          i += str.size + 2
        elsif sub.start_with? "Method: "
          tokens << [:METHOD, LexedChunk.new("Method:", line, @line_no, i + 1)]
          debug_out("Extracted Method: (Definition)")
          i += "Method: ".size
        elsif sub.start_with? "Class: "
          tokens << [:CLASS, LexedChunk.new("Class:", line, @line_no, i + 1)]
          debug_out("Extracted Class: (Definition)")
          i += "Class: ".size
        elsif sub.start_with? "Contract: "
          tokens << [:CONTRACT, LexedChunk.new("Contract:", line, @line_no, i + 1)]
          debug_out("Extracted Contract: (Definition)")
          i += "Contract: ".size
        elsif sub.start_with? "Enumerate: "
          tokens << [:ENUM, LexedChunk.new("Enumerate:", line, @line_no, i + 1)]
          debug_out("Extracted Enumerate: (Definition)")
          i += "Enumerate: ".size
        elsif sub.start_with? "is "
          tokens << [:IS, LexedChunk.new("is", line, @line_no, i + 1)]
          debug_out("Extracted is (Keyword)")
          i += "is ".size
        elsif sub.start_with? "as "
          tokens << [:AS, LexedChunk.new("as", line, @line_no, i + 1)]
          debug_out("Extracted as (Keyword)")
          i += "as ".size
        elsif identifier = sub[/\A(\w+\.\w+)(\)|\s|$)/, 1]
          id = sub[/\A(\w+)/, 1]
          tokens << [:IDENTIFIER, LexedChunk.new(id, line, @line_no, i + 1)]
          debug_out("Extracted #{id} (Identifier)")
          i += id.size

          i += 1 # period

          id = sub[/\A(\w+)\.(\w+)/, 2]
          tokens << [:FIELD, LexedChunk.new(id, line, @line_no, i + 1)]
          debug_out("Extracted #{id} (Field)")
          i += id.size
        elsif identifier = sub[/\Afor (\w+) in /, 1]
          tokens << [:FOR, LexedChunk.new("for", line, @line_no, i + 1)]
          debug_out("Extracted for (Keyword)")
          i += 4 # "for "

          tokens << [:IDENTIFIER, LexedChunk.new(identifier, line, @line_no, i + 1)]
          debug_out("Extracted #{identifier} (Identifier)")
          i += identifier.size

          tokens << [:IN, LexedChunk.new("in", line, @line_no, i + 1 + 1)]
          debug_out("Extracted in (Keyword)")
          i += 4 # " in "
        elsif identifiers = sub[/\Afor (\w+, \w+) in /, 1]
          tokens << [:FOR, LexedChunk.new("for", line, @line_no, i + 1)]
          debug_out("Extracted for (Keyword)")
          i += 4 # "for "

          key = identifiers.split(", ").first
          tokens << [:IDENTIFIER, LexedChunk.new(key, line, @line_no, i + 1)]
          debug_out("Extracted #{key} (Identifier)")
          i += key.size

          tokens << [',', LexedChunk.new(", ", line, @line_no, i + 1)]
          debug_out("Extracted , (Operator)")
          i += 2 # ", "

          val = identifiers.split(", ").last
          tokens << [:IDENTIFIER, LexedChunk.new(val, line, @line_no, i + 1)]
          debug_out("Extracted #{val} (Identifier)")
          i += val.size

          tokens << [:IN, LexedChunk.new("in", line, @line_no, i + 1 + 1)]
          debug_out("Extracted in (Keyword)")
          i += 4 # " in "
        elsif identifier = sub[/\A(\w+[\?!])\(/, 1]
          tokens << [:IDENTIFIER, LexedChunk.new(identifier, line, @line_no, i + 1)]
          debug_out("Extracted #{identifier} (Identifier)")
          i += identifier.size
        elsif identifier = sub[/\A(\w+)/, 1]
          if KEYWORDS.include? identifier
            tokens << [identifier.upcase.to_sym, LexedChunk.new(identifier, line, @line_no, i + 1)]
            debug_out("Extracted #{identifier} (Keyword)")
          else
            tokens << [:IDENTIFIER, LexedChunk.new(identifier, line, @line_no, i + 1)]
            debug_out("Extracted #{identifier} (Identifier)")
          end
          i += identifier.size
        elsif "()" == sub[0..1]
          tokens << ["()", LexedChunk.new("()", line, @line_no, i + 1)]
          i += 2
          debug_out("Extracted () (Operator)")
        elsif "( " == sub[0..1]
          tokens << ["( ", LexedChunk.new("( ", line, @line_no, i + 1)]
          i += 2
          debug_out("Extracted ( (Operator)")
        elsif " )" == sub[0..1]
          tokens << [" )", LexedChunk.new(" )", line, @line_no, i + 1)]
          i += 2
          debug_out("Extracted ) (Operator)")
        elsif op = sub[/\A( [=+-\/^*<>] )/, 1]
          tok = op.strip
          tokens << [tok, LexedChunk.new(op, line, @line_no, i + 1)]
          i += op.size
          debug_out("Extracted #{tok} (Operator)")
        elsif op = sub[/\A([:,])[ \n]/, 1]
          tok = op.strip
          tokens << [tok, LexedChunk.new(op + " ", line, @line_no, i + 1)]
          i += op.size + 1
          debug_out("Extracted #{tok} (Operator)")
        elsif op = sub[/\A(&&|\|\|)/, 1]
          tokens << [op, LexedChunk.new(op, line, @line_no, i + 1)]
          i += 2
          debug_out("Extracted #{op} (Operator)")
        elsif op = sub[/\A(==|!=|<=|>=|=>)/, 1]
          tokens << [op, LexedChunk.new(op, line, @line_no, i + 1)]
          i += 2
          debug_out("Extracted #{op} (Operator)")
        elsif op = sub[/\A([().?!\[\]{}#])/, 1]
          tokens << [op, LexedChunk.new(op, line, @line_no, i + 1)]
          i += op.size
          debug_out("Extracted #{op} (Operator)")
        elsif space = sub[/\A(\s*\n)/m, 1]
          tokens << [:NEWLINE, LexedChunk.new("\n", line, @line_no, i + space.size)]
          i += space.size
          debug_out("Extracted newline")
        elsif space = sub[/\A(\s+)/, 1]
          i += space.size
          debug_out("Extracted whitespace")
        else
          raise LexError.new(line, sub.rstrip, @line_no, i + 1)
        end
      end

      tokens
    end

    def debug_out(message)
      puts message if @debug
    end
end
