# The base object everything inherits from
class DaisyObject
  attr_accessor :runtime_class, :ruby_value, :instance_data

  def initialize(runtime_class, ruby_value=self)
    @runtime_class = runtime_class
    @ruby_value = ruby_value
    @instance_data = {}
  end

  def dispatch(context, message, args)
    method = @runtime_class.lookup(message)
    return method.call(context.interpreter, self, args) unless method.nil?

    method = @runtime_class.lookup_dispatch() if method.nil?
    method.call(self, message, args) unless method.nil?
    unknown_message(message, args)
  end

  def copy
    return self if @instance_data.nil? || @instance_data.empty?
    cp = DaisyObject.new(@runtime_class, @ruby_value)
    cp.instance_data = @instance_data.clone
    cp
  end

  def unknown_message(message, args)
    # Todo: This should error-handle via Daisy code paths, not Ruby
    raise "Received unknown message '#{message}' for '#{@runtime_class.name}'"
  end

  def hash
    @ruby_value.hash
  end

  def ==(o)
    @ruby_value == o.ruby_value
  end

  def eql?(o)
    @runtime_class == o.runtime_class && @ruby_value == o.ruby_value
  end
end
