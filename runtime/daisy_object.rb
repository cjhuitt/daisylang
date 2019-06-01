# The base object everything inherits from
class DaisyObject
  attr_accessor :runtime_class

  def initialize(runtime_class)
    @runtime_class = runtime_class
  end

  def call(message, args)
    unknown_message(message, args)
  end

  def unknown_message(message, args)
    # Todo: This should error-handle via Daisy code paths, not Ruby
    raise "Received unknown message #{message} for #{@runtime_class}"
  end

  def new
    DaisyObject.new(self)
  end
end
