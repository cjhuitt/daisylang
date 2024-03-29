Constants["Array"] = DaisyClass.new("Array", Constants["Object"])
RootContext.symbols["Array"] = Constants["Array"]

Constants["Array"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Array"].def :toString do |interpreter, receiver, args|
  if receiver.ruby_value.empty?
    Constants["String"].new("[]")
  else
    strings = receiver.ruby_value.map { |item|
      stringify = Constants["Object"].lookup("to_str")
      stringify.call(interpreter, item, args)
    }
    Constants["String"].new( "[#{strings.join(", ")}]" )
  end
end

Constants["Array"].def :+ do |interpreter, receiver, args|
  result = receiver.ruby_value + args.first[1].ruby_value
  Constants["Array"].new(result)
end

Constants["Array"].add_contract(Constants["Verifiable"].ruby_value)
Constants["Array"].def :'?' do |interpreter, receiver, args|
  receiver.ruby_value.nil? || receiver.ruby_value.empty? ? Constants["false"] : Constants["true"]
end

Constants["Array"].add_contract(Constants["Countable"].ruby_value)
Constants["Array"].def :empty? do |interpreter, receiver, args|
  receiver.ruby_value.empty? ? Constants["true"] : Constants["false"]
end
Constants["Array"].def :count do |interpreter, receiver, args|
  Constants["Integer"].new(receiver.ruby_value.count)
end

Constants["Array"].add_contract(Constants["Indexable"].ruby_value)
Constants["Array"].def :'#' do |interpreter, receiver, args|
  index = args.first[1]
  raise "Array index must be an integer" if index.runtime_class != Constants["Integer"]
  receiver.ruby_value[index.ruby_value] || Constants["none"]
end

Constants["Array"].def :append! do |interpreter, receiver, args|
  args.each do |arg|
    receiver.ruby_value << arg[1].ruby_value
  end
  receiver
end
