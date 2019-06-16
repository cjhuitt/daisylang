Constants["Contract"] = DaisyClass.new("Contract", Constants["Object"])
RootContext.symbols["Contract"] = Constants["Contract"]

Constants["Stringifiable"] = Constants["Contract"].new(DaisyContract.new("Stringifiable"))
RootContext.symbols["Stringifiable"] = Constants["Stringifiable"]
Constants["Stringifiable"].runtime_class.def :toString do end
Constants["Class"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["String"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["None"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Function"].add_contract(Constants["Stringifiable"].ruby_value)

Constants["Contract"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Contract"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end

Constants["Equatable"] = Constants["Contract"].new(DaisyContract.new("Equatable"))
RootContext.symbols["Equatable"] = Constants["Equatable"]
Constants["Equatable"].runtime_class.def :== do end
Constants["Equatable"].runtime_class.def :!= do end
Constants["Object"].add_contract(Constants["Equatable"].ruby_value)
Constants["Class"].add_contract(Constants["Equatable"].ruby_value)
Constants["String"].add_contract(Constants["Equatable"].ruby_value)
Constants["Function"].add_contract(Constants["Equatable"].ruby_value)

Constants["Contract"].add_contract(Constants["Equatable"].ruby_value)
Constants["Contract"].def :== do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["true"] if receiver.ruby_value == other.ruby_value
  Constants["false"]
end
Constants["Contract"].def :!= do |interpreter, receiver, args|
  other = args.first[1]
  return Constants["false"] if receiver.ruby_value == other.ruby_value
  Constants["true"]
end

Constants["Comperable"] = Constants["Contract"].new(DaisyContract.new("Comperable"))
RootContext.symbols["Comperable"] = Constants["Comperable"]
Constants["Comperable"].runtime_class.def :< do end
Constants["Comperable"].runtime_class.def :<= do end
Constants["Comperable"].runtime_class.def :> do end
Constants["Comperable"].runtime_class.def :>= do end
