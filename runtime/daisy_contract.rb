require 'daisy_object'

class DaisyContract < DaisyObject
  attr_accessor :defined_methods
  attr_reader :name

  def initialize(name)
    super(Constants["Contract"])
    @name = name
    @defined_methods = {}
  end

  def is_type(type)
    return self == type
  end

  def lookup(message)
    @defined_methods[message]
  end

  def defines?(message)
    @defined_methods.key?(message)
  end

  def add_method(method)
    @defined_methods[method.name] = method
  end

  # Helper methods to use this class in ruby:
  def def(name, &block)
    @defined_methods[name.to_s] = block
  end

  def new(value=nil)
    DaisyObject.new(self, value)
  end

  def ==(o)
    @name == o.name
  end

  def eql?(o)
    self.class == o.class && @name == o.name
  end
end

