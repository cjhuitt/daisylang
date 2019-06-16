Constants["Contract"] = DaisyClass.new("Contract", Constants["Object"])
RootContext.symbols["Contract"] = Constants["Contract"]

Constants["Stringifiable"] = Constants["Contract"].new(DaisyContract.new("Stringifiable"))
RootContext.symbols["Stringifiable"] = Constants["Stringifiable"]
Constants["Class"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["String"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["None"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Function"].add_contract(Constants["Stringifiable"].ruby_value)

Constants["Contract"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Contract"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end

Constants["Comperable"] = Constants["Contract"].new(DaisyContract.new("Comperable"))
RootContext.symbols["Comperable"] = Constants["Comperable"]
Constants["Comperable"].runtime_class.def :< do end
Constants["Comperable"].runtime_class.def :<= do end
Constants["Comperable"].runtime_class.def :> do end
Constants["Comperable"].runtime_class.def :>= do end
