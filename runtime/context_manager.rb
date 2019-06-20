require 'context'

class ContextManager
  attr_accessor :context

  def initialize(root_context)
    @context = root_context
    @context_queue = []
  end

  def enter_method_context(receiver)
    @context_queue.push(@context)
    @context = Context.new(@context, receiver)
  end

  def enter_class_definition_context(daisy_class)
    @context_queue.push(@context)
    @context = Context.new(@context, daisy_class, daisy_class)
    @context.defining_class = daisy_class
    @context
  end

  def enter_contract_definition_context(contract)
    @context_queue.push(@context)
    @context = Context.new(@context, contract, contract)
  end

  def leave_context(context)
    raise "Leaving inactive context" if !context.nil? && context != @context
    @context = @context_queue.pop()
  end
end

