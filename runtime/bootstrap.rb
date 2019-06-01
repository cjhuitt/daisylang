Constants = {}

Constants["Class"] = DaisyClass.new
Constants["Class"].runtime_class = Constants["Class"]
Constants["Object"] = DaisyClass.new
Constants["String"] = DaisyClass.new(Constants["Object"])

root_self = Constants["Object"].new
RootContext = Context.new(root_self)

Constants["Object"].def :print do |receiver, args|
  puts "#{args}"
end
