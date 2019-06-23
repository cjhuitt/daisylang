Constants["Hash"] = DaisyClass.new("Hash", Constants["Object"])
RootContext.symbols["Hash"] = Constants["Hash"]

Constants["Hash"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Hash"].def :toString do |interpreter, receiver, args|
  if receiver.ruby_value.empty?
    Constants["String"].new("{}")
  else
    stringify = Constants["Object"].lookup("to_str")
    strings = receiver.ruby_value.map { |key, value|
      stringify.call(interpreter, item, []) + " => " +
        stringify.call(interpreter, value, [])
    }
    Constants["String"].new( "{#{strings.join(", ")}}" )
  end
end
