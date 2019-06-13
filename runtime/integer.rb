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

Constants["Integer"].add_contract(Constants["Sortable"].ruby_value)
Constants["Integer"].def :< do |interpreter, receiver, args|
  result = receiver.ruby_value < args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :<= do |interpreter, receiver, args|
  result = receiver.ruby_value <= args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :> do |interpreter, receiver, args|
  result = receiver.ruby_value > args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :>= do |interpreter, receiver, args|
  result = receiver.ruby_value >= args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :'?' do |interpreter, receiver, args|
  receiver.ruby_value.nil? ? Constants["false"] : Constants["true"]
end

Constants["Integer"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Integer"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{args.first[1].ruby_value}" )
end
