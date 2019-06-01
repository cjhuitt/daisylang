$:.unshift File.expand_path("../../", __FILE__)

require 'parser'

class Interpreter
  def initialize
    @parser = Parser.new
  end

  def eval(code)
    puts @parser.parse(code)
  end
end

