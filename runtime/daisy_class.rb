require 'daisy_object'

class DaisyClass < DaisyObject
  attr_accessor :runtime_methods, :runtime_superclass, :contracts, :fields
  attr_reader :name

  def initialize(name, superclass=nil)
    super(Constants["Class"])
    @name = name
    @runtime_methods = {}
    @contracts = {}
    @fields = {}
    @runtime_superclass = superclass
  end

  def is_type(type)
    return self == type ||
      (!@runtime_superclass.nil? && @runtime_superclass.is_type(type))
  end

  def has_contract(contract)
    return @contracts.key?(contract.name) ||
      (!@runtime_superclass.nil? && @runtime_superclass.has_contract(contract))
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

  def add_contract(contract)
    contracts[contract.name] = contract
  end

  def assign_field(name, value)
    @fields[name] = value
  end

  def field(name)
    value = @fields[name]
    if !value.nil? || @runtime_superclass.nil?
      value
    else
      @runtime_superclass.field(name)
    end
  end

  # Helper methods to use this class in ruby:
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  def new(value=nil)
    obj = DaisyObject.new(self, value)
    @fields.each do |name, field|
      obj.instance_data[name] = field
    end
    obj
  end
end
