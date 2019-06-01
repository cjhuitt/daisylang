class Lexer
  def tokenize(code)
    blocklevel = 0
    tokens = []
    code.lines.each do |line|
      indent = line[/\A */].size
      blocks = indent / 4
      if blocks == blocklevel + 1
        tokens << [:BLOCKSTART, blocks]
        blocklevel = blocks
      else blocks < blocklevel
        while blocks < blocklevel
          tokens << [:BLOCKEND, blocklevel]
          blocklevel -= 1
        end
      end
      tokens += tokenize_line(line)
      tokens << [:NEWLINE, "\n"]
    end
    tokens.pop unless code.end_with? "\n"
    tokens
  end

  private
    KEYWORDS = ["Function", "None", "pass", "return"]

    def tokenize_line(line)
      # Bail early on an empty line
      return [] if line.strip.empty?

      tokens = []
      line.split.each do |chunk|
        tokens += tokenize_chunk(chunk)
        tokens << [:WHITESPACE, " "]
      end
      tokens.pop

      tokens
    end

    def tokenize_chunk(chunk)
      tokens = []

      # Go through by matched somethings
      i = 0
      while i < chunk.size
        sub = chunk[i..-1]
        if integer = sub[/\A(\d+)/, 1]
          tokens << [:INTEGER, integer.to_i]
          i += integer.size
        elsif identifier = sub[/\A(\w+)/, 1]
          if KEYWORDS.include? identifier
            tokens << [identifier.upcase.to_sym, identifier]
          else
            tokens << [:IDENTIFIER, identifier]
          end
          i += identifier.size
        elsif op = sub[/\A([:()=+-\/^*])/, 1]
          tokens << [op, op]
          i += 1
        end
      end

      tokens
    end
end
