require 'daisy_object'

class DaisyClass < DaisyObject
  attr_accessor :runtime_methods

  def initialize()
    super(Constants["Class"])
    @runtime_methods = {}
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

  def new
    DaisyObject.new(self)
  end
end
