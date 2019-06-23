require 'daisy_object'

class DaisyEnumValue < DaisyObject
  attr_reader :name, :category, :value

  def initialize(name, category, value)
    super(Constants["EnumValue"])
    @name = name
    @category = category
    @value = Constants["Integer"].new(value)
  end

  def hash
    @name.hash
  end

  def ==(o)
    @name == o.name
  end

  def eql?(o)
    self.category == o.category && @name == o.name
  end
end

class DaisyEnumCategory < DaisyObject
  include Enumerable

  attr_reader :name, :values

  def initialize(name)
    super(Constants["EnumCategory"])
    @name = name
    @values = {}
  end

  def is_type(type)
    return self == type
  end

  def add(typename)
    raise "Error: Adding enum value with identical name '#{typename}'" if @values.key? typename
    @values[typename] = DaisyEnumValue.new(typename, self, @values.count)
  end

  def each
    if block_given?
      @values.values.each do |value|
        yield value
      end
    else
      @values.values.each
    end
  end

  def ==(o)
    @name == o.name
  end

  def eql?(o)
    self.class == o.class && @name == o.name
  end
end

