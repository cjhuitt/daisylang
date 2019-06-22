require 'daisy_object'

class DaisyEnumEntry < DaisyObject
  attr_reader :name, :type

  def initialize(name, type)
    @name = name
    @type = type
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
    @types[typename] = DaisyEnumEntry.new(typename, self)
  end
end

