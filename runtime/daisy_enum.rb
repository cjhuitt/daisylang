require 'daisy_object'

class DaisyEnum < DaisyObject
  attr_reader :name, :types

  def initialize(name)
    @name = name
    @types = {}
  end

  def is_type(type)
    return self == type
  end

  def add(typename)
    raise "Error: Adding enum type with identical name '#{typename}'" if @types.key? typename
    @types[typename] = nil
  end
end

