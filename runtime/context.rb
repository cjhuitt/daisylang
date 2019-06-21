class Context
  attr_reader :previous_context, :current_self, :current_class
  attr_accessor :interpreter, :symbols
  attr_accessor :return_type, :return_value, :should_return
  attr_accessor :defining_class
  attr_accessor :last_file_context
  attr_accessor :last_method_context, :current_method_context
  attr_accessor :current_loop_context, :should_break

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
    @last_file_context = nil
    @last_method_context = nil
    @current_method_context = nil
    @current_loop_context = nil
    @should_break = false
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
        inst = symbol(instance, nil)
        raise "Unknown symbol #{instance}" if inst.nil?
        raise "Unknown field #{name} in #{inst.runtime_class.name}" if !inst.instance_data.key?(name)
        inst.instance_data[name] = value
      elsif !@current_self.instance_data.nil? && @current_self.instance_data.key?(name)
        @current_self.instance_data[name] = value
      elsif !@previous_context.nil? && !@previous_context.symbol(name, instance).nil?
        @previous_context.assign_symbol(name, instance, value)
      else
        @symbols[name] = value
      end
    else
      @defining_class.assign_field(name, value)
    end
  end

  def symbol(name, instance)
    if !instance.nil?
      inst = symbol(instance, nil)
      raise "Unknown symbol #{instance}" if inst.nil?
      return inst.instance_data[name]
    end
    value = @symbols[name]
    return value if !value.nil?
    if !@current_self.instance_data.nil?
      value = @current_self.instance_data[name]
      return value if !value.nil?
    end
    return @previous_context.symbol(name, instance) if !@previous_context.nil?
    nil
  end

  def add_method(method)
    @current_class.add_method(method)
  end

  def set_return(val)
    if !@current_method_context.nil?
      @current_method_context.return_value = val
      @current_method_context.should_return = true
    end
  end

  def set_should_break
    if !@current_loop_context.nil?
      @current_loop_context.should_break = true
    end
  end

  def need_early_exit
    return (!@current_method_context.nil? && @current_method_context.should_return) ||
           (!@current_loop_context.nil? && @current_loop_context.should_break)
  end
end
