require 'daisy_object'

class DaisyClass < DaisyObject
  attr_accessor :runtime_methods, :runtime_superclass

  def initialize(superclass=nil)
    super(Constants["Class"])
    @runtime_methods = {}
    @runtime_superclass = superclass
  end

  def lookup(message)
    @runtime_methods[message]
  end

  def lookup_dispatch()
    @runtime_methods["dispatch"]
  end

  # Helper methods to use this class in ruby:
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  def new(value=nil)
    DaisyObject.new(self, value)
  end
end