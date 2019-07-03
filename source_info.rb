class SourceInfo < Struct.new(:text, :line, :col)
  def initialize(text, line, col)
    super(text, line, col)
  end
end

