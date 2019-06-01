class Lexer
  def initialize(debug=false)
    @string_accumulator = nil
    @debug = debug
  end

  def tokenize(code)
    blocklevel = 0
    tokens = []
    code.lines.each do |line|
      debug_out("Tokenizing line >>#{line}<<")
      if indent = line[/\A( +)/, 1]
        blocks = indent.size / 4
        if blocks == blocklevel + 1
          tokens << [:BLOCKSTART, blocks]
          blocklevel = blocks
        else blocks < blocklevel
          while blocks < blocklevel
            tokens << [:BLOCKEND, blocklevel]
            blocklevel -= 1
          end
        end
        line.delete_prefix!(indent)
      elsif 0 < blocklevel
          while 0 < blocklevel
            tokens << [:BLOCKEND, blocklevel]
            blocklevel -= 1
          end
      end
      tokens += tokenize_line(line)
    end
    tokens
  end

  private
    KEYWORDS = ["Function", "None", "pass", "return"]

    def tokenize_line(line)
      return tokenize_chunk(line)
      tokens = []
      line.split.each do |chunk|
        debug_out("Tokenizing chunk >>#{chunk}<<")
        tokens += tokenize_chunk(chunk)
        if @string_accumulator.nil?
          tokens << [:WHITESPACE, " "]
        else
          @string_accumulator += " "
        end
      end
      tokens.pop

      tokens
    end

    def tokenize_chunk(chunk)
      tokens = []
      i = 0

      unless @string_accumulator.nil?
        if str = chunk[/\A(.*)"/, 1]
          i += str.size + 1
          @string_accumulator += str;
          debug_out("Extracted \"#{@string_accumulator}\" (String)")
          tokens << [:STRING, @string_accumulator]
          @string_accumulator = nil
        else
          @string_accumulator += chunk
          return
        end
      end

      while i < chunk.size
        sub = chunk[i..-1]
        debug_out("Checking partial >>#{sub}<<")
        if integer = sub[/\A(\d+)/, 1]
          tokens << [:INTEGER, integer.to_i]
          i += integer.size
          debug_out("Extracted #{integer} (Integer)")
        elsif str = sub[/\A"(.*)"/, 1]
          tokens << [:STRING, str]
          i += str.size + 2
          debug_out("Extracted \"#{str}\" (String)")
        elsif str = sub[/\A"(.*)\z/, 1]
          @string_accumulator = str
          i += str.size + 2
        elsif identifier = sub[/\A(\w+)/, 1]
          if KEYWORDS.include? identifier
            tokens << [identifier.upcase.to_sym, identifier]
            debug_out("Extracted #{identifier} (Keyword)")
          else
            tokens << [:IDENTIFIER, identifier]
            debug_out("Extracted #{identifier} (Identifier)")
          end
          i += identifier.size
        elsif space = sub[/\A(\s*\n)/m, 1]
          tokens << [:NEWLINE, "\n"]
          i += space.size
          debug_out("Extracted newline")
        elsif space = sub[/\A(\s+)/, 1]
          tokens << [:WHITESPACE, " "]
          i += space.size
          debug_out("Extracted whitespace")
        elsif op = sub[/\A([:()=+-\/^*])/, 1]
          tokens << [op, op]
          i += 1
          debug_out("Extracted #{op} (Operator)")
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
