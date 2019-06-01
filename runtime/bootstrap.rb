Constants = {}

Constants["Class"] = DaisyClass.new
Constants["Class"].runtime_class = Constants["Class"]
Constants["Object"] = DaisyClass.new
Constants["String"] = DaisyClass.new(Constants["Object"])
Constants["Integer"] = DaisyClass.new(Constants["Object"])
Constants["None"] = DaisyClass.new(Constants["Object"])

Constants["none"] = Constants["None"].new(nil)

root_self = Constants["Object"].new
RootContext = Context.new(root_self)

Constants["Object"].def :print do |receiver, args|
  message = args.map { |arg| arg[1].ruby_value }
  puts message
end

Constants["None"].def :print do |receiver, args|
  puts "(none)"
end

Constants["Integer"].def :+ do |receiver, args|
  result = receiver.ruby_value + args.first[1].ruby_value
  Constants["Integer"].new(result)
end
