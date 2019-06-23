Constants["EnumCategory"] = DaisyClass.new("EnumCategory", Constants["Object"])
RootContext.symbols["EnumCategory"] = Constants["EnumCategory"]

Constants["EnumCategory"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["EnumCategory"].def :toString do |interpreter, receiver, args|
  values = receiver.values.keys.join(", ")
  Constants["String"].new( "#{receiver.name} (#{values})" )
end
Constants["EnumCategory"].def :name do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end
Constants["EnumCategory"].def :values do |interpreter, receiver, args|
  Constants["Array"].new( receiver.values.values )
end


Constants["EnumValue"] = DaisyClass.new("EnumValue", Constants["Object"])
RootContext.symbols["EnumValue"] = Constants["EnumValue"]

Constants["EnumValue"].add_contract(Constants["Stringifiable"].ruby_value)
Constants["EnumValue"].def :toString do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}(#{receiver.value.ruby_value})" )
end
Constants["EnumValue"].def :name do |interpreter, receiver, args|
  Constants["String"].new( "#{receiver.name}" )
end
Constants["EnumValue"].def :value do |interpreter, receiver, args|
  receiver.value
end
Constants["EnumValue"].def :category do |interpreter, receiver, args|
  receiver.category
end

