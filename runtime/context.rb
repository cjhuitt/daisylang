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

  def assign_symbol(name, instance, value)
    if @defining_class.nil?
      if @symbols.key?(name)
        @symbols[name] = value
      elsif !instance.nil?
        sym = symbol(instance)
        raise "Unknown field #{name} in #{sym.runtime_class.name}" if !sym.instance_data.key?(name)
        sym.instance_data[name] = value
      elsif !@current_self.instance_data.nil? && @current_self.instance_data.key?(name)
        @current_self.instance_data[name] = value
      elsif !@previous_context.nil? && !@previous_context.symbol(name).nil?
        @previous_context.assign_symbol(name, instance, value)
      else
        @symbols[name] = value
      end
    else
      @defining_class.assign_field(name, value)
    end
  end

  def symbol(name)
    value = @symbols[name]
    return value if !value.nil?
    if !@current_self.instance_data.nil?
      value = @current_self.instance_data[name]
      return value if !value.nil?
    end
    return @previous_context.symbol(name) if !@previous_context.nil?
    nil
  end

  def add_method(method)
    @current_class.add_method(method)
  end
end
