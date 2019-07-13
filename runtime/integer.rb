Constants["Integer"] = DaisyClass.new("Integer", Constants["Object"])
RootContext.symbols["Integer"] = Constants["Integer"]

Constants["Integer"].def :+ do |interpreter, receiver, args|
  result = receiver.ruby_value + args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :- do |interpreter, receiver, args|
  result = receiver.ruby_value - args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :* do |interpreter, receiver, args|
  result = receiver.ruby_value * args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :/ do |interpreter, receiver, args|
  result = receiver.ruby_value / args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :^ do |interpreter, receiver, args|
  result = receiver.ruby_value ** args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].add_contract(Constants["Equatable"].ruby_value)
Constants["Integer"].def :== do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["true"] if receiver.ruby_value == other.ruby_value
  Constants["false"]
end
Constants["Integer"].def :!= do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["false"] if receiver.ruby_value == other.ruby_value
  Constants["true"]
end

Constants["Integer"].add_contract(Constants["Comperable"].ruby_value)
Constants["Integer"].def :< do |interpreter, receiver, args|
  receiver.ruby_value < args.first[1].ruby_value ? Constants["true"] : Constants["false"]
end

Constants["Integer"].def :<= do |interpreter, receiver, args|
  receiver.ruby_value <= args.first[1].ruby_value ? Constants["true"] : Constants["false"]
end

Constants["Integer"].def :> do |interpreter, receiver, args|
  receiver.ruby_value > args.first[1].ruby_value ? Constants["true"] : Constants["false"]
end

Constants["Integer"].def :>= do |interpreter, receiver, args|
  receiver.ruby_value >= args.first[1].ruby_value ? Constants["true"] : Constants["false"]
end

Constants["Integer"].add_contract(Constants["Verifiable"].ruby_value)
Constants["Integer"].def :'?' do |interpreter, receiver, args|
  receiver.ruby_value.nil? ? Constants["false"] : Constants["true"]
end

Constants["Integer"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Integer"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.ruby_value}" )
end
Constants["Integer"].def :toHex do |interpreter, receiver, args|
  Constants["String"].new( "%02x" % receiver.ruby_value )
end
