Constants["Hash"] = DaisyClass.new("Hash", Constants["Object"])
RootContext.symbols["Hash"] = Constants["Hash"]

Constants["Hash"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Hash"].def :toString do |interpreter, receiver, args|
  if receiver.ruby_value.empty?
    Constants["String"].new("{}")
  else
    stringify = Constants["Object"].lookup("to_str")
    strings = receiver.ruby_value.map { |key, value|
      stringify.call(interpreter, key, []) + " => " +
        stringify.call(interpreter, value, [])
    }
    Constants["String"].new( "{#{strings.join(", ")}}" )
  end
end

Constants["Hash"].def :+ do |interpreter, receiver, args|
  result = receiver.ruby_value.update(args.first[1].ruby_value)
  Constants["Hash"].new(result)
end

Constants["Hash"].add_contract(Constants["Verifiable"].ruby_value)
Constants["Hash"].def :'?' do |interpreter, receiver, args|
  receiver.ruby_value.nil? || receiver.ruby_value.empty? ? Constants["false"] : Constants["true"]
end

Constants["Hash"].add_contract(Constants["Countable"].ruby_value)
Constants["Hash"].def :empty? do |interpreter, receiver, args|
  receiver.ruby_value.empty? ? Constants["true"] : Constants["false"]
end
Constants["Hash"].def :count do |interpreter, receiver, args|
  Constants["Integer"].new(receiver.ruby_value.count)
end

Constants["Hash"].add_contract(Constants["Indexable"].ruby_value)
Constants["Hash"].def :'#' do |interpreter, receiver, args|
  index = args.first[1]
  receiver.ruby_value[index.ruby_value]
end

Constants["Hash"].def :append! do |interpreter, receiver, args|
  args.each do |arg|
    receiver.ruby_value.update(arg[1].ruby_value)
  end
  receiver
end

Constants["Hash"].def :keys do |interpreter, receiver, args|
  Constants["Array"].new(receiver.ruby_value.keys)
end
Constants["Hash"].def :values do |interpreter, receiver, args|
  Constants["Array"].new(receiver.ruby_value.values)
end

