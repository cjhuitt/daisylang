
class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node unless node.nil?
    self
  end
end

class IntegerNode < Struct.new(:value)
end

class NoneNode < Struct.new(:value)
  def initialize
    super(nil)
  end
end

class ReturnNode < Struct.new(:value)
end

class SendMessageNode < Struct.new(:receiver, :message, :arguments)
end

class ArgumentNode < Struct.new(:label, :value)
end
