class Context
  attr_reader :previous_context, :current_self, :current_class
  attr_accessor :interpreter, :defined_types, :locals

  def initialize(prev_context, current_self, current_class=current_self.runtime_class)
    @previous_context = prev_context
    @current_self = current_self
    @current_class = current_class
    @interpreter = interpreter
    @defined_types = {}
    @locals = {}
  end

  def interpreter()
    if @interpreter.nil? && !@previous_context.nil?
      @previous_context.interpreter
    else
      @interpreter
    end
  end

  def definition_of(def_type)
    type = @defined_types[def_type]
    if !type.nil? || @previous_context.nil?
      type
    else
      @previous_context.definition_of(def_type)
    end
  end

  def value_for(name)
    value = @locals[name]
    if !value.nil? || @previous_context.nil?
      value
    else
      @previous_context.value_for(name)
    end
  end
end
