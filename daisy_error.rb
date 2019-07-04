require "source_info"

class DaisyError < StandardError
  attr_reader :source_info
  def initialize(msg, source_info)
    super(msg)
    @source_info = source_info
  end
end

