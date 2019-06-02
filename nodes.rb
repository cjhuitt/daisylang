
module Visitable
  def accept(visitor)
    visitor.visit self
  end
end

class Nodes < Struct.new(:nodes)
  include Visitable

  def <<(node)
    nodes << node unless node.nil?
    self
  end
end

class LiteralNode < Struct.new(:value);
  include Visitable
end

class IntegerNode < LiteralNode; end
class StringNode < LiteralNode; end
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

class SendMessageNode < Struct.new(:receiver, :message, :arguments);
  include Visitable
end

class DefineMessageNode < Struct.new(:name, :return_type,
                                     :argument_types, :body);
  include Visitable
end


class ArgumentNode < Struct.new(:label, :value);
  include Visitable
end

class ConditionalNode < Struct.new(:condition, :body); end
class IfNode < ConditionalNode
  include Visitable
end

class GetVariableNode < Struct.new(:id)
  include Visitable
end
