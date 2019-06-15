class Context
  attr_reader :previous_context, :current_self, :current_class
  attr_accessor :interpreter, :symbols
  attr_accessor :return_type, :return_value, :should_return
  attr_accessor :defining_class

  def initialize(prev_context, current_self, current_class=current_self.runtime_class)
    @previous_context = prev_context
    @current_self = current_self
    @current_class = current_class
    @interpreter = interpreter
    @symbols = {}
    @return_type = Constants["None"]
    @return_value = Constants["none"]
    @should_return = false
    @defining_class = nil
  end

  def interpreter()
    if @interpreter.nil? && !@previous_context.nil?
      @previous_context.interpreter
    else
      @interpreter
    end
  end

  def assign_symbol(name, value)
    if @defining_class.nil?
      @symbols[name] = value
    else
      @defining_class.assign_field(name, value)
    end
  end

  def symbol(name)
    value = @symbols[name]
    if !value.nil? || @previous_context.nil?
      value
    else
      @previous_context.symbol(name)
    end
  end

  def add_method(method)
    @current_class.add_method(method)
  end
end
