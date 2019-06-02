class Context
  attr_reader :current_self, :current_class
  attr_accessor :interpreter, :defined_types

  def initialize(current_self, interpreter, current_class=current_self.runtime_class)
    @current_self = current_self
    @current_class = current_class
    @interpreter = interpreter
    @defined_types = {}
  end
end
