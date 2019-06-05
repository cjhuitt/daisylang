Constants = {}

Constants["Class"] = DaisyClass.new("Class")
Constants["Class"].runtime_class = Constants["Class"]

Constants["Object"] = DaisyClass.new("Object")
Constants["Object"].def :print do |interpreter, receiver, args|
  message = args.map { |arg| arg[1].ruby_value }
  puts message
end

root_self = Constants["Object"].new
RootContext = Context.new(nil, root_self)

RootContext.defined_types["Object"] = Constants["Object"]
RootContext.defined_types["Class"] = Constants["Class"]

Constants["String"] = DaisyClass.new("String", Constants["Object"])
RootContext.defined_types["String"] = Constants["String"]

Constants["None"] = DaisyClass.new("None", Constants["Object"])
RootContext.defined_types["None"] = Constants["None"]
Constants["None"].def :print do |receiver, args|
  puts "(none)"
end
Constants["None"].def :'?' do |interpreter, receiver, args|
  Constants["false"]
end

Constants["none"] = Constants["None"].new(nil)

