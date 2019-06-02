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
    puts "Need to appropriately implement calling #{@name}"
    @body.accept(interpreter)
  end
end

