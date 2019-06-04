
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
class TrueNode < LiteralNode
  def initialize
    super(true)
  end
end
class FalseNode < LiteralNode
  def initialize
    super(false)
  end
end

class SendMessageNode < Struct.new(:receiver, :message, :arguments)
  include Visitable
end

class DefineMessageNode < Struct.new(:name, :return_type,
                                     :parameters, :body)
  include Visitable
end
class ReturnNode < Struct.new(:expression)
  include Visitable
end

class ArgumentNode < Struct.new(:label, :value)
  include Visitable
end

class VariableNode < Struct.new(:label, :type, :value)
  include Visitable
end
class ParameterNode < VariableNode; end

class ConditionalNode < Struct.new(:condition, :body); end
class IfNode < ConditionalNode
  include Visitable
end
class UnlessNode < ConditionalNode
  include Visitable
end

class GetVariableNode < Struct.new(:id)
  include Visitable
end
class SetVariableNode < Struct.new(:id, :value)
  include Visitable
end

class CommentNode < Struct.new(:text)
  include Visitable
end
