Constants["Contract"] = DaisyClass.new("Contract", Constants["Object"])
RootContext.symbols["Contract"] = Constants["Contract"]

Constants["Stringifiable"] = DaisyContract.new("Stringifiable")
RootContext.symbols["Stringifiable"] = Constants["Stringifiable"]
Constants["Stringifiable"].runtime_class.def :toString do end
Constants["Class"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["String"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["None"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Method"].add_contract(Constants["Stringifiable"].ruby_value)

Constants["Contract"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Contract"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end

Constants["Equatable"] = DaisyContract.new("Equatable")
RootContext.symbols["Equatable"] = Constants["Equatable"]
Constants["Equatable"].runtime_class.def :== do end
Constants["Equatable"].runtime_class.def :!= do end
Constants["Object"].add_contract(Constants["Equatable"].ruby_value)
Constants["Class"].add_contract(Constants["Equatable"].ruby_value)
Constants["String"].add_contract(Constants["Equatable"].ruby_value)
Constants["Method"].add_contract(Constants["Equatable"].ruby_value)

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

Constants["Comperable"] = DaisyContract.new("Comperable")
RootContext.symbols["Comperable"] = Constants["Comperable"]
Constants["Comperable"].runtime_class.def :< do end
Constants["Comperable"].runtime_class.def :<= do end
Constants["Comperable"].runtime_class.def :> do end
Constants["Comperable"].runtime_class.def :>= do end

Constants["Verifiable"] = DaisyContract.new("Verifiable")
RootContext.symbols["Verifiable"] = Constants["Verifiable"]
Constants["Verifiable"].runtime_class.def :'?' do end
Constants["None"].add_contract(Constants["Verifiable"].ruby_value)
Constants["String"].add_contract(Constants["Verifiable"].ruby_value)

Constants["Countable"] = DaisyContract.new("Countable")
RootContext.symbols["Countable"] = Constants["Countable"]
Constants["Countable"].runtime_class.def :empty? do end
Constants["Countable"].runtime_class.def :count do end

Constants["Indexable"] = DaisyContract.new("Indexable")
RootContext.symbols["Indexable"] = Constants["Indexable"]
Constants["Indexable"].runtime_class.def :'#' do end

Constants["Throwable"] = DaisyContract.new("Throwable")
RootContext.symbols["Throwable"] = Constants["Throwable"]
