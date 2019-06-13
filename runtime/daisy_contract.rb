require 'daisy_object'

class DaisyContract < DaisyObject
  attr_accessor :defined_methods, :runtime_superclass
  attr_reader :contract_name

  def initialize(contract_name, superclass=nil)
    super(Constants["Contract"])
    @contract_name = contract_name
    @defined_methods = {}
    @runtime_superclass = superclass
  end

  def is_type(type)
    return self == type
  end

  def defines?(message)
    @defined_methods.contains?(message)
  end

  def add_method(method)
    @defined_methods[method.name] = method
  end

  # Helper methods to use this class in ruby:
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  def new(value=nil)
    DaisyObject.new(self, value)
  end
end

