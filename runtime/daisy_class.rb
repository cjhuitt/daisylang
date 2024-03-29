require 'daisy_object'

class DaisyClass < DaisyObject
  attr_accessor :runtime_methods, :runtime_superclass, :fields
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
    @contracts[contract.name] = contract
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

  def types
    types = []
    types += @runtime_superclass.types if !@runtime_superclass.nil?
    types += @contracts.keys
    types << @name
    types.uniq
  end

  def contracts
    contracts = []
    contracts += @runtime_superclass.contracts if !@runtime_superclass.nil?
    contracts += @contracts.keys
    contracts.uniq
  end

  def daisy_methods
    methods = []
    methods += @runtime_superclass.daisy_methods if !@runtime_superclass.nil?
    methods += @runtime_methods.keys
    methods.uniq
  end

  # Helper methods to use this class in ruby:
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  def new(value=nil)
    instance = DaisyObject.new(self, value)
    add_fields_to(instance)
  end

  def add_fields_to(instance)
    @fields.each do |name, field|
      instance.instance_data[name] = field
    end
    @runtime_superclass.add_fields_to(instance) if !@runtime_superclass.nil?
    instance
  end

  def hash
    @name.hash
  end

  def ==(o)
    @name == o.name
  end

  def eql?(o)
    self.class == o.class && @name == o.name
  end
end
