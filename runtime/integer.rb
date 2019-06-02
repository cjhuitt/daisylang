Constants["Integer"] = DaisyClass.new(Constants["Object"])
RootContext.defined_types["Integer"] = Constants["Integer"]

Constants["Integer"].def :+ do |receiver, args|
  result = receiver.ruby_value + args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :- do |receiver, args|
  result = receiver.ruby_value - args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :* do |receiver, args|
  result = receiver.ruby_value * args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :/ do |receiver, args|
  result = receiver.ruby_value / args.first[1].ruby_value
  Constants["Integer"].new(result)
end

Constants["Integer"].def :^ do |receiver, args|
  result = receiver.ruby_value ** args.first[1].ruby_value
  Constants["Integer"].new(result)
end
