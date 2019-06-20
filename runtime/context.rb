class ContextManager
  attr_accessor :context

  def initialize(root_context)
    @context = root_context
  end

  def enter_method_context(new_self)
    @context = Context.new(@context, new_self)
  end

  def enter_class_definition_context(daisy_class)
    @context = Context.new(@context, daisy_class, daisy_class)
    @context.defining_class = daisy_class
  end

  def enter_contract_definition_context(contract)
    @context = Context.new(@context, contract, contract)
  end

  def leave_context(context=nil)
    raise "Leaving inactive context" if !context.nil? && context != @context
    @context = @context.previous_context
  end
end

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
end
