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
          tokens.pop if tokens.last == [:NEWLINE, "\n"]
          tokens << [:BLOCKSTART, blocks]
          blocklevel = blocks
        else blocks < blocklevel
          tokens.pop if tokens.last == [:NEWLINE, "\n"]
          while blocks < blocklevel
            tokens << [:BLOCKEND, blocklevel]
            blocklevel -= 1
          end
        end
        line.delete_prefix!("    " * blocklevel)
      elsif 0 < blocklevel
          tokens.pop if tokens.last == [:NEWLINE, "\n"]
          while 0 < blocklevel
            tokens << [:BLOCKEND, blocklevel]
            blocklevel -= 1
          end
      end if @string_accumulator.nil?
      tokens += tokenize_line(line)
    end
    tokens
  end

  private
    KEYWORDS = ["Function", "None", "pass", "return", "if", "true", "false",
                "none"]

    def tokenize_line(line)
      tokens = []
      i = 0

      unless @string_accumulator.nil?
        if str = line[/\A([^"]*)"/, 1]
          i += str.size + 1
          @string_accumulator += str;
          debug_out("Extracted \"#{@string_accumulator}\" (String)")
          tokens << [:STRING, @string_accumulator]
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
          tokens << [:COMMENT, sub]
          break
        elsif integer = sub[/\A(\d+)/, 1]
          tokens << [:INTEGER, integer.to_i]
          i += integer.size
          debug_out("Extracted #{integer} (Integer)")
        elsif str = sub[/\A"([^"]*)"/, 1]
          tokens << [:STRING, str]
          i += str.size + 2
          debug_out("Extracted \"#{str}\" (String)")
        elsif str = sub[/\A"([^"]*)/, 1]
          @string_accumulator = str
          i += str.size + 2
        elsif identifier = sub[/\A(\w+)/, 1]
          if KEYWORDS.include? identifier
            if identifier == "None"
              tokens << [:NONETYPE, identifier]
            else
              tokens << [identifier.upcase.to_sym, identifier]
            end
            debug_out("Extracted #{identifier} (Keyword)")
          else
            tokens << [:IDENTIFIER, identifier]
            debug_out("Extracted #{identifier} (Identifier)")
          end
          i += identifier.size
        elsif "()" == sub[0..1]
          tokens << ["()", "()"]
          i += 2
          debug_out("Extracted () (Operator)")
        elsif "( " == sub[0..1]
          tokens << ["( ", "( "]
          i += 2
          debug_out("Extracted ( (Operator)")
        elsif " )" == sub[0..1]
          tokens << [" )", " )"]
          i += 2
          debug_out("Extracted ) (Operator)")
        elsif op = sub[/\A( [=+-\/^*] )/, 1]
          tok = op.strip
          tokens << [tok, op]
          i += op.size
          debug_out("Extracted #{tok} (Operator)")
        elsif op = sub[/\A([:,] )/, 1]
          tok = op.strip
          tokens << [tok, op]
          i += op.size
          debug_out("Extracted #{tok} (Operator)")
        elsif op = sub[/\A([().])/, 1]
          tokens << [op, op]
          i += op.size
          debug_out("Extracted #{op} (Operator)")
        elsif op = sub[/\A(&&|\|\|)/, 1]
          tokens << [op, op]
          i += 2
          debug_out("Extracted #{op} (Operator)")
        elsif op = sub[/\A(==|!=|<=|>=)/, 1]
          tokens << [op, op]
          i += 2
          debug_out("Extracted #{op} (Operator)")
        elsif space = sub[/\A(\s*\n)/m, 1]
          tokens << [:NEWLINE, "\n"]
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
