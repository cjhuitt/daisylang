Constants = {}

Constants["Class"] = DaisyClass.new("Class")
Constants["Class"].runtime_class = Constants["Class"]

Constants["Object"] = DaisyClass.new("Object")
Constants["Class"].runtime_superclass = Constants["Object"]
Constants["Object"].def :print do |interpreter, receiver, args|
  daisy_class = args.first[1].runtime_class
  if daisy_class.has_contract(Constants["Stringifiable"].ruby_value)
    formatter = args.first[1].runtime_class.lookup("toString")
    message = formatter.call(interpreter, receiver, args)
    puts message.ruby_value
  else
    puts "<#{daisy_class.name}:#{args.first[1].object_id}>"
  end
end
Constants["Object"].def :type do |interpreter, receiver, args|
  receiver.runtime_class
end
Constants["Object"].def :'isa?' do |interpreter, receiver, args|
  if receiver.runtime_class.is_type( args.first[1] )
    Constants["true"]
  else
    Constants["false"]
  end
end
Constants["Object"].def :'is?' do |interpreter, receiver, args|
  if receiver.runtime_class.has_contract( args.first[1].ruby_value )
    Constants["true"]
  else
    Constants["false"]
  end
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
Constants["Class"].def :default do |interpreter, receiver, args|
  receiver.new
end
Constants["Class"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( args.first[1].class_name )
end

RootContext.symbols["Object"] = Constants["Object"]
RootContext.symbols["Class"] = Constants["Class"]

Constants["String"] = DaisyClass.new("String", Constants["Object"])
RootContext.symbols["String"] = Constants["String"]
Constants["String"].def :toString do |interpreter, receiver, args|
  args.first[1]
end

Constants["None"] = DaisyClass.new("None", Constants["Object"])
RootContext.symbols["None"] = Constants["None"]
Constants["None"].def :toString do |interpreter, receiver, args|
  Constants["String"].new("(none)")
end
Constants["None"].def :'?' do |interpreter, receiver, args|
  Constants["false"]
end

Constants["none"] = Constants["None"].new(nil)

Constants["Function"] = DaisyClass.new("Function", Constants["Object"])
RootContext.symbols["Function"] = Constants["Function"]
Constants["Function"].def :toString do |interpreter, receiver, args|
  method = args.first[1].ruby_value
  params = method.params.map { |param| "#{param.label}: #{param.type}" }.join( " " )
  if params.empty?
    params = "()"
  else
    params = "( " + params + " )"
  end
  Constants["String"].new( "Function #{method.return_type.name} #{method.name}#{params}" )
end

