Constants["Contract"] = DaisyClass.new("Contract", Constants["Object"])
RootContext.symbols["Contract"] = Constants["Contract"]

Constants["Stringifiable"] = Constants["Contract"].new(DaisyContract.new("Stringifiable"))
RootContext.symbols["Stringifiable"] = Constants["Stringifiable"]
Constants["Class"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["String"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["None"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Function"].add_contract(Constants["Stringifiable"].ruby_value)

Constants["Sortable"] = Constants["Contract"].new(DaisyContract.new("Sortable"))
RootContext.symbols["Sortable"] = Constants["Sortable"]

Constants["Contract"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Contract"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end
