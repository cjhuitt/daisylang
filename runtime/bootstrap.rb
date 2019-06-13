Constants = {}

Constants["Class"] = DaisyClass.new("Class")
Constants["Class"].runtime_class = Constants["Class"]

Constants["Object"] = DaisyClass.new("Object")
Constants["Class"].runtime_superclass = Constants["Object"]
Constants["Object"].def :print do |interpreter, receiver, args|
  formatter = args.first[1].runtime_class.lookup("printable")
  message = formatter.call(interpreter, receiver, args)
  puts message.ruby_value
end
Constants["Object"].def :type do |interpreter, receiver, args|
  receiver.runtime_class
end
Constants["Object"].def :default do |interpreter, receiver, args|
  receiver.new
end
Constants["Object"].def :'isa?' do |interpreter, receiver, args|
  if receiver.runtime_class.is_type( args.first[1] )
    Constants["true"]
  else
    Constants["false"]
  end
end
Constants["Object"].def :printable do |interpreter, receiver, args|
  Constants["String"].new( "Instance of #{args.first[1].runtime_class.name}" )
end

root_self = Constants["Object"].new
RootContext = Context.new(nil, root_self)

Constants["Class"].def :== do |interpreter, receiver, args|
  if receiver == args.first[1]
    Constants["true"]
  else
    Constants["false"]
  end
end
Constants["Class"].def :!= do |interpreter, receiver, args|
  if receiver == args.first[1]
    Constants["false"]
  else
    Constants["true"]
  end
end
Constants["Class"].def :printable do |interpreter, receiver, args|
  Constants["String"].new( args.first[1].name )
end

RootContext.symbols["Object"] = Constants["Object"]
RootContext.symbols["Class"] = Constants["Class"]

Constants["String"] = DaisyClass.new("String", Constants["Object"])
RootContext.symbols["String"] = Constants["String"]
Constants["String"].def :printable do |interpreter, receiver, args|
  args.first[1]
end

Constants["None"] = DaisyClass.new("None", Constants["Object"])
RootContext.symbols["None"] = Constants["None"]
Constants["None"].def :printable do |interpreter, receiver, args|
  Constants["String"].new("(none)")
end
Constants["None"].def :'?' do |interpreter, receiver, args|
  Constants["false"]
end

Constants["none"] = Constants["None"].new(nil)

Constants["Function"] = DaisyClass.new("Function", Constants["Object"])
RootContext.symbols["Function"] = Constants["Function"]
Constants["Function"].def :printable do |interpreter, receiver, args|
  method = args.first[1].ruby_value
  params = method.params.map { |param| "#{param.label}: #{param.type}" }.join( " " )
  if params.empty?
    params = "()"
  else
    params = "( " + params + " )"
  end
  Constants["String"].new( "Function #{method.return_type.name} #{method.name}#{params}" )
end

############### Contracts
Constants["Contract"] = DaisyContract.new("Contract", Constants["Object"])
RootContext.symbols["Contract"] = Constants["Contract"]
###############
