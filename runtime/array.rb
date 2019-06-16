Constants["Array"] = DaisyClass.new("Array", Constants["Object"])
RootContext.symbols["Array"] = Constants["Array"]

Constants["Array"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Array"].def :toString do |interpreter, receiver, args|
  return Constants["String"].new("[]") if receiver.ruby_value.empty?
  strings = receiver.ruby_value.map { |item|
    stringify = Constants["Object"].lookup("to_str")
    stringify.call(interpreter, item, args)
  }
  Constants["String"].new( "[#{strings.join(", ")}]" )
end

Constants["Array"].def :+ do |interpreter, receiver, args|
  result = receiver.ruby_value + args.first[1].ruby_value
  Constants["Array"].new(result)
end

Constants["Array"].add_contract(Constants["Verifiable"].ruby_value)
Constants["Array"].def :'?' do |interpreter, receiver, args|
  receiver.ruby_value.nil? || receiver.ruby_value.empty? ? Constants["false"] : Constants["true"]
end
