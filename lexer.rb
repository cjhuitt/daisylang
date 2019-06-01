class Lexer
  def tokenize(code)
    tokens = []
    code.lines.each do |line|
      tokens += tokenize_line(line)
    end
    tokens
  end

  private
    def tokenize_line(line)
      tokens = []
      tokens << [:INTEGER, 1]
      tokens
    end
end
