class Lexer
  def tokenize(code)
    tokens = []
    code.lines.each do |line|
      tokens += tokenize_line(line)
    end
    tokens << [:NEWLINE, "\n"] if code.end_with? "\n"
    tokens
  end

  KEYWORDS = ["Function", "return"]

  private
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
      if integer = chunk[/\A(\d+)/, 1]
        tokens << [:INTEGER, integer.to_i]
      elsif identifier = chunk[/\A(\w+)/, 1]
        if KEYWORDS.include? identifier
          tokens << [identifier.upcase.to_sym, identifier]
        else
          tokens << [:IDENTIFIER, identifier]
        end
      elsif op = chunk[/\A([:()=+-\/^*])/, 1]
          tokens << [op, op]
      end

      tokens
    end
end
