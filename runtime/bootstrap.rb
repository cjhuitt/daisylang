Constants = {}

Constants["Class"] = DaisyClass.new("Class")
Constants["Class"].runtime_class = Constants["Class"]

Constants["Object"] = DaisyClass.new("Object")
Constants["Class"].runtime_superclass = Constants["Object"]
Constants["Object"].def :print do |interpreter, receiver, args|
  daisy_obj = args.first[1]
  daisy_class = daisy_obj.runtime_class
  if daisy_class.has_contract(Constants["Stringifiable"].ruby_value)
    formatter = daisy_class.lookup("toString")
    message = formatter.call(interpreter, daisy_obj, [])
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
Constants["Object"].def :== do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["true"] if receiver.ruby_value == other.ruby_value
  Constants["false"]
end
Constants["Object"].def :!= do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["false"] if receiver.ruby_value == other.ruby_value
  Constants["true"]
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
Constants["Class"].def :create do |interpreter, receiver, args|
  obj = receiver.new
  init = receiver.lookup("init")
  if !init.nil?
    init.call(interpreter, obj, args)
  end
  obj
end
Constants["Class"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( receiver.name )
end

RootContext.symbols["Object"] = Constants["Object"]
RootContext.symbols["Class"] = Constants["Class"]

Constants["String"] = DaisyClass.new("String", Constants["Object"])
RootContext.symbols["String"] = Constants["String"]
Constants["String"].def :toString do |interpreter, receiver, args|
  receiver
end
Constants["String"].def :+ do |interpreter, receiver, args|
  Constants["String"].new( receiver.ruby_value + args.first[1].ruby_value )
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
  method = receiver.ruby_value
  params = method.params.map { |param| "#{param.label}: #{param.type}" }.join( " " )
  if params.empty?
    params = "()"
  else
    params = "( " + params + " )"
  end
  Constants["String"].new( "Function #{method.return_type.name} #{method.name}#{params}" )
end
Constants["Function"].def :== do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["true"] if receiver.ruby_value == other.ruby_value
  Constants["false"]
end
Constants["Function"].def :!= do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["false"] if receiver.ruby_value == other.ruby_value
  Constants["true"]
end

