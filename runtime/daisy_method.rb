require 'daisy_object'

class DaisyParameter < Struct.new(:label, :type, :value); end

class DaisyMethod < DaisyObject
  attr_reader :name, :return_type, :params

  def initialize(name, return_type, params, body)
    @name = name
    @return_type = return_type
    @params = params
    @body = body
  end

  def call(interpreter, receiver, args)
    interpreter.execute_method(receiver, arglist(args), @return_type, @body)
  end

  private
    def arglist(args)
      case @params.count
      when 0
        {}
      when 1
        one_param_arglist(args)
      else
        many_param_arglist(args)
      end
    end

    def one_param_arglist(args)
      raise "Too many arguments to method #{@name}" if args.count > 1
      if args.count == 1
        { params.first.label => args.first[1] }
      else
        raise "Parameter to method #{@name} required" if params.first.value.nil?
        { params.first.label => params.first.value }
      end
    end

    def many_param_arglist(args)
      given_dict = {}
      args.each do |label, value|
        given_dict[label] = value
      end

      args_dict = {}
      @params.each do |param|
        if val = given_dict.delete(param.label)
          args_dict[param.label] = val
        else
          raise "Parameter #{param.label} to method #{@name} required" if param.value.nil?
          args_dict[param.label] = param.value
        end
      end
      raise "Too many parameters passed to method #{@name}" unless given_dict.empty?
      args_dict
    end
end

