
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

class DefineMethodNode < Struct.new(:name, :return_type,
                                     :parameters, :body)
  include Visitable
end
class ReturnNode < Struct.new(:expression)
  include Visitable
end

class ArgumentNode < Struct.new(:label, :value)
  include Visitable
end

class SymbolNode < Struct.new(:label, :type, :value)
  include Visitable
end
class ParameterNode < SymbolNode; end

class ConditionBlockNode < Struct.new(:condition, :body, :comment); end

class IfNode < Struct.new(:condition_blocks, :else_block)
  include Visitable
end

class UnlessNode < Struct.new(:condition_block, :else_block)
  include Visitable
end

class WhileNode < Struct.new(:condition_block)
  include Visitable
end

class ForNode < Struct.new(:container, :variable, :body, :comment)
  include Visitable
end

class LoopNode < Struct.new(:body, :comment)
  include Visitable
end

class BreakNode < LiteralNode
  def initialize
    super(nil)
  end
end

class ContinueNode < LiteralNode
  def initialize
    super(nil)
  end
end


class GetSymbolNode < Struct.new(:id, :instance)
  include Visitable
end
class SetSymbolNode < Struct.new(:id, :value, :instance)
  include Visitable
end

class CommentNode < Struct.new(:text)
  include Visitable
end

class DefineContractNode < Struct.new(:name, :body)
  include Visitable
end

class DefineClassNode < Struct.new(:name, :contracts, :body)
  include Visitable
end

class EnumerateNode < Struct.new(:name, :symbols)
  include Visitable
end

class ArrayNode < Struct.new(:members)
  include Visitable
end
