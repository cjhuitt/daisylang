Constants["Boolean"] = DaisyClass.new(Constants["Object"])
RootContext.defined_types["Boolean"] = Constants["Boolean"]
Constants["true"] = Constants["Boolean"].new(true)
Constants["false"] = Constants["Boolean"].new(false)

#Constants["Boolean"].def :== do |interpreter, receiver, args|
#  Constants["true"] if receiver.ruby_value == args.first[1].ruby_value
#end

#Constants["Boolean"].def :!= do |interpreter, receiver, args|
#end
#
#Constants["Boolean"].def :&& do |interpreter, receiver, args|
#end
#
#Constants["Boolean"].def :|| do |interpreter, receiver, args|
#end

