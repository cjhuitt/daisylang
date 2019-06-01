
class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node
    self
  end
end

class IntegerNode < Struct.new(:value)
end
