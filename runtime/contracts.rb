Constants["Contract"] = DaisyClass.new("Contract", Constants["Object"])
RootContext.symbols["Contract"] = Constants["Contract"]

Constants["Sortable"] = Constants["Contract"].new(DaisyContract.new("Sortable"))
RootContext.symbols["Sortable"] = Constants["Sortable"]
