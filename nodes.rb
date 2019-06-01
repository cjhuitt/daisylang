
class Nodes < Struct.new(:nodes)
  def <<(node)
    nodes << node unless node.nil?
    self
  end
end

class LiteralNode < Struct.new(:value); end

class IntegerNode < LiteralNode; end
class ReturnNode < LiteralNode; end

class NoneNode < LiteralNode
  def initialize
    super(nil)
  end
end

class PassNode < LiteralNode
  def initialize
    super(nil)
  end
end

class SendMessageNode < Struct.new(:receiver, :message, :arguments); end

class DefineMessageNode < Struct.new(:name, :return_type,
                                     :argument_types, :body); end


class ArgumentNode < Struct.new(:label, :value); end
