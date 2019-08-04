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

  def hash
    @name.hash
  end

  def ==(o)
    @name == o.name
  end

  def eql?(o)
    self.class == o.class && @name == o.name
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
      default = nil
      args.each do |label, value|
        if label.nil?
          raise "Only one argument may be given without using labels" if !default.nil?
          default = value
        else
          given_dict[label] = value
        end
      end

      args_dict = {}
      @params.each do |param|
        if val = given_dict.delete(param.label)
          args_dict[param.label] = val
        else
          if param.value == Constants["none"]
            if !default.nil?
              args_dict[param.label] = default
              default = nil
            else
              raise "Parameter #{param.label} required for method #{@name}"
            end
          else
            args_dict[param.label] = param.value
          end
        end
      end
      raise "Too many parameters passed to method #{@name}" unless given_dict.empty?
      args_dict
    end
end

class DaisyDelegatedMethod < DaisyObject

  def initialize(object, method)
    @object = object
    @method = method
  end

  def call(interpreter, receiver, args)
    @method.call(interpreter, @object, args)
  end

  def hash
    @method.name.hash
  end

  def ==(o)
    @object == o.object && @method.name == o.method.name
  end

  def eql?(o)
    self.class == o.class && @name == o.name
  end
end


