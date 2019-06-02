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

    context = interpreter.push_context(receiver)
    arglist(args).each do |name, value|
      context.locals[name] = value
    end

    result = @body.accept(interpreter)
    interpreter.pop_context
    result
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
        { params.first[0] => args.first[1] }
      else
        raise "Parameter to method #{@name} required" if params.first.value.nil?
        { params.first[0] => params.first[1] }
      end
    end

    def many_param_arglist(args)
      given_dict = {}
      args.each do |label, value|
        given_dict[label] = value
      end

      args_dict = {}
      @params.each do |label, value|
        if val = given_dict.delete(label)
          context.locals[label] = val
        else
          raise "Parameter #{label} to method #{@name} required" if value.nil?
          context.locals[label] = value
        end
      end
      raise "Too many parameters passed to method #{@name}" unless given_dict.empty
      args_dict
    end
end

