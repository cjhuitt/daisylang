Constants = {}

Constants["Class"] = DaisyClass.new
Constants["Class"].runtime_class = Constants["Class"]

Constants["Object"] = DaisyClass.new
Constants["Object"].def :print do |receiver, args|
  message = args.map { |arg| arg[1].ruby_value }
  puts message
end

root_self = Constants["Object"].new
RootContext = Context.new(root_self)

RootContext.defined_types["Object"] = Constants["Object"]
RootContext.defined_types["Class"] = Constants["Class"]

Constants["String"] = DaisyClass.new(Constants["Object"])
RootContext.defined_types["String"] = Constants["String"]

Constants["None"] = DaisyClass.new(Constants["Object"])
RootContext.defined_types["None"] = Constants["None"]
Constants["None"].def :print do |receiver, args|
  puts "(none)"
end

Constants["none"] = Constants["None"].new(nil)

