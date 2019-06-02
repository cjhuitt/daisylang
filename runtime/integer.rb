Constants["Integer"] = DaisyClass.new(Constants["Object"])

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
