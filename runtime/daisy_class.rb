require 'daisy_object'

class DaisyClass < DaisyObject
  attr_accessor :runtime_methods, :runtime_superclass
  attr_reader :class_name

  def initialize(class_name, superclass=nil)
    super(Constants["Class"])
    @class_name = class_name
    @runtime_methods = {}
    @runtime_superclass = superclass
  end

  def is_type(type)
    return self == type ||
      (!@runtime_superclass.nil? && @runtime_superclass.is_type(type))
  end

  def lookup(message)
    method = @runtime_methods[message]
    unless method
      method = @runtime_superclass.lookup(message) if @runtime_superclass
    end
    method
  end

  def lookup_dispatch()
    @runtime_methods["dispatch"]
  end

  def add_method(method)
    runtime_methods[method.name] = method
  end

  # Helper methods to use this class in ruby:
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  def new(value=nil)
    DaisyObject.new(self, value)
  end
end
