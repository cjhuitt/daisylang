Constants["Float"] = DaisyClass.new("Float", Constants["Object"])
RootContext.symbols["Float"] = Constants["Float"]

Constants["Float"].def :+ do |interpreter, receiver, args|
  result = receiver.ruby_value + args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].def :- do |interpreter, receiver, args|
  result = receiver.ruby_value - args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].def :* do |interpreter, receiver, args|
  result = receiver.ruby_value * args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].def :/ do |interpreter, receiver, args|
  result = receiver.ruby_value / args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].def :^ do |interpreter, receiver, args|
  result = receiver.ruby_value ** args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].add_contract(Constants["Comperable"].ruby_value)
Constants["Float"].def :< do |interpreter, receiver, args|
  result = receiver.ruby_value < args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].def :<= do |interpreter, receiver, args|
  result = receiver.ruby_value <= args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].def :> do |interpreter, receiver, args|
  result = receiver.ruby_value > args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].def :>= do |interpreter, receiver, args|
  result = receiver.ruby_value >= args.first[1].ruby_value
  Constants["Float"].new(result)
end

Constants["Float"].add_contract(Constants["Equatable"].ruby_value)
Constants["Float"].def :== do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["true"] if receiver.ruby_value == other.ruby_value
  Constants["false"]
end
Constants["Float"].def :!= do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["false"] if receiver.ruby_value == other.ruby_value
  Constants["true"]
end

Constants["Float"].add_contract(Constants["Verifiable"].ruby_value)
Constants["Float"].def :'?' do |interpreter, receiver, args|
  receiver.ruby_value.nil? ? Constants["false"] : Constants["true"]
end

Constants["Float"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Float"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.ruby_value}" )
end
