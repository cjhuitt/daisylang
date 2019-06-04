Constants["Boolean"] = DaisyClass.new(Constants["Object"])
RootContext.defined_types["Boolean"] = Constants["Boolean"]
Constants["true"] = Constants["Boolean"].new(true)
Constants["false"] = Constants["Boolean"].new(false)

Constants["Boolean"].def :== do |interpreter, receiver, args|
  if receiver.ruby_value == args.first[1].ruby_value
    Constants["true"]
  else
    Constants["false"]
  end
end

Constants["Boolean"].def :!= do |interpreter, receiver, args|
  if receiver.ruby_value == args.first[1].ruby_value
    Constants["false"]
  else
    Constants["true"]
  end
end

Constants["Boolean"].def :! do |interpreter, receiver, args|
  if receiver.ruby_value
    Constants["false"]
  else
    Constants["true"]
  end
end

Constants["Boolean"].def :'?' do |interpreter, receiver, args|
  receiver
end

Constants["Boolean"].def :'&&' do |interpreter, receiver, args|
  if receiver.ruby_value && args.first[1].ruby_value
    Constants["true"]
  else
    Constants["false"]
  end
end

Constants["Boolean"].def :'||' do |interpreter, receiver, args|
  if receiver.ruby_value || args.first[1].ruby_value
    Constants["true"]
  else
    Constants["false"]
  end
end

