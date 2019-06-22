require 'daisy_object'

class DaisyEnumEntry < DaisyObject
  attr_reader :name, :category, :value

  def initialize(name, category, value)
    super(Constants["EnumEntry"])
    @name = name
    @category = category
    @value = Constants["Integer"].new(value)
  end
end

class DaisyEnumCategory < DaisyObject
  attr_reader :name, :entries

  def initialize(name)
    super(Constants["EnumCategory"])
    @name = name
    @entries = {}
  end

  def is_type(type)
    return self == type
  end

  def add(typename)
    raise "Error: Adding enum entry with identical name '#{typename}'" if @entries.key? typename
    @entries[typename] = DaisyEnumEntry.new(typename, self, @entries.count)
  end
end

