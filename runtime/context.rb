class Context
  attr_reader :current_self

  def initialize(current_self)
    @current_self = current_self
  end
end
