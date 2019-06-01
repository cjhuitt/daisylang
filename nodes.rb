
class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node unless node.nil?
    self
  end
end

class IntegerNode < Struct.new(:value)
end
