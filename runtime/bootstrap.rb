Constants = {}

Constants["Class"] = DaisyClass.new
Constants["Class"].runtime_class = Constants["Class"]
Constants["Object"] = DaisyClass.new

root_self = Constants["Object"].new
RootContext = Context.new(root_self)
