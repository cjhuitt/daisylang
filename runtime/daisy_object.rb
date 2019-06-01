# The base object everything inherits from
class DaisyObject
  attr_accessor :runtime_class, :ruby_value

  def initialize(runtime_class, ruby_value=nil)
    @runtime_class = runtime_class
    @ruby_value = ruby_value
  end

  def dispatch(message, args)
    method = @runtime_class.lookup(message)
    return method.call(self, args) unless method.nil?

    method = @runtime.class.lookup_dispatch() if method.nil?
    method.call(self, message, args) unless method.nil?
    unknown_message(message, args)
  end

  def unknown_message(message, args)
    # Todo: This should error-handle via Daisy code paths, not Ruby
    raise "Received unknown message #{message} for #{@runtime_class}"
  end
end
