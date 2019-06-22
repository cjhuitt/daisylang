Constants["EnumCategory"] = DaisyClass.new("EnumCategory", Constants["Object"])
RootContext.symbols["EnumCategory"] = Constants["EnumCategory"]

Constants["EnumCategory"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["EnumCategory"].def :toString do |interpreter, receiver, args|
  values = receiver.entries.keys.join(", ")
  Constants["String"].new( "#{receiver.name} (#{values})" )
end
Constants["EnumCategory"].def :name do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end


Constants["EnumEntry"] = DaisyClass.new("EnumEntry", Constants["Object"])
RootContext.symbols["EnumEntry"] = Constants["EnumEntry"]

Constants["EnumEntry"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["EnumEntry"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}(#{receiver.value.ruby_value})" )
end
Constants["EnumEntry"].def :name do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end
Constants["EnumEntry"].def :value do |interpreter, receiver, args|
  receiver.value
end
Constants["EnumEntry"].def :category do |interpreter, receiver, args|
  receiver.category
end

