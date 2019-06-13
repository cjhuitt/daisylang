Constants["Boolean"] = DaisyClass.new("Boolean", Constants["Object"])
RootContext.symbols["Boolean"] = Constants["Boolean"]
Constants["true"] = Constants["Boolean"].new(true)
Constants["false"] = Constants["Boolean"].new(false)

Constants["Boolean"].def :check_compat do |other|
  if other.runtime_class != Constants["Boolean"] &&
      other.runtime_class != Constants["None"]
    raise "Type error mismatch"
  end
end

Constants["Boolean"].def :== do |interpreter, receiver, args|
  val = args.first[1]
  Constants["Boolean"].lookup('check_compat').call(val)
  if receiver.ruby_value == val.ruby_value
    Constants["true"]
  else
    Constants["false"]
  end
end

Constants["Boolean"].def :!= do |interpreter, receiver, args|
  val = args.first[1]
  Constants["Boolean"].lookup('check_compat').call(val)
  if receiver.ruby_value == val.ruby_value
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
  val = args.first[1]
  Constants["Boolean"].lookup('check_compat').call(val)
  if receiver.ruby_value && val.ruby_value
    Constants["true"]
  else
    Constants["false"]
  end
end

Constants["Boolean"].def :'||' do |interpreter, receiver, args|
  val = args.first[1]
  Constants["Boolean"].lookup('check_compat').call(val)
  if receiver.ruby_value || val.ruby_value
    Constants["true"]
  else
    Constants["false"]
  end
end

Constants["Boolean"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["Boolean"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{args.first[1].ruby_value}" )
end

