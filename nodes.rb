
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
class FloatNode < LiteralNode; end
class StringNode < LiteralNode; end

class NilNode < LiteralNode
  def initialize
    super(nil)
  end
end
class NoneNode < NilNode; end
class PassNode < NilNode; end
class BreakNode < NilNode; end
class ContinueNode < NilNode; end

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

class LabeledValueNode < Struct.new(:label, :value)
  include Visitable
end
class ArgumentNode < LabeledValueNode; end
class ParameterNode < LabeledValueNode; end
class HashEntryNode < LabeledValueNode; end

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
class StandardForNode < Struct.new(:container, :variable, :body, :comment)
  include Visitable
end
class KeyValueForNode < Struct.new(:container, :key_symbol, :value_symbol, :body, :comment)
  include Visitable
end
class SwitchNode < Struct.new(:value, :condition_blocks, :else_block)
  include Visitable
end

class LoopNode < Struct.new(:body, :comment)
  include Visitable
end

class TryNode < Struct.new(:comment, :body, :handlers)
  include Visitable
end
class HandleNode < Struct.new(:type, :as, :comment, :body)
  include Visitable
end
class ThrowNode < Struct.new(:exception)
  include Visitable
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

class IsContractNode < Struct.new(:name, :source_info); end
class DefineClassNode < Struct.new(:name, :contracts, :body)
  include Visitable
end

class EnumerateNode < Struct.new(:name, :symbols)
  include Visitable
end

class ArrayNode < Struct.new(:members)
  include Visitable
end

class HashNode < Struct.new(:members)
  include Visitable
end
