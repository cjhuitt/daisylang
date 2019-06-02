require 'daisy_object'

class DaisyMethod < DaisyObject
  attr_reader :name, :return_type, :params

  def initialize(name, return_type, params, body)
    @name = name
    @return_type = return_type
    @params = params
    @body = body
  end

  def call(interpreter, receiver, args)
    context = interpreter.push_context(receiver)
    puts "Need to appropriately implement calling #{@name}"
    result = @body.accept(interpreter)
    interpreter.pop_context
    result
  end
end

