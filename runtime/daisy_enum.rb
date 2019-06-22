require 'daisy_object'

class DaisyEnumEntry < DaisyObject
  attr_reader :name, :type, :value

  def initialize(name, type, value)
    @name = name
    @type = type
    @value = value
  end
end

class DaisyEnum < DaisyObject
  attr_reader :name, :types

  def initialize(name)
#    super(Constants["Enum"])
    @name = name
    @types = {}
  end

  def is_type(type)
    return self == type
  end

  def add(typename)
    raise "Error: Adding enum type with identical name '#{typename}'" if @types.key? typename
    @types[typename] = DaisyEnumEntry.new(typename, self, @types.count)
  end
end

