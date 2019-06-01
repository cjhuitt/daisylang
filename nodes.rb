
class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node
    self
  end
end
