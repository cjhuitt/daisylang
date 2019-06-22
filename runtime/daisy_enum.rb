require 'daisy_object'

class DaisyEnum < DaisyObject
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def is_type(type)
    return self == type
  end

end

