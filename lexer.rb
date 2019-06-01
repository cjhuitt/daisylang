class Lexer
  def tokenize(code)
    tokens = []
    code.lines.each do |line|
      tokens += tokenize_line(line)
    end
    tokens << [:NEWLINE, "\n"] if code.end_with? "\n"
    tokens
  end

  private
    def tokenize_line(line)
      # Bail early on an empty line
      return [] if line.strip.empty?
      tokens = []
      tokens << [:INTEGER, line.to_i]
      tokens
    end
end
