require 'context'

class ContextManager
  attr_accessor :context

  def initialize(root_context)
    @root_context = root_context
    @context = @root_context
    @last_file_context = nil
    @last_method_context = nil
    @context_queue = []
  end

  def enter_file_scope(file)
    @context_queue.push(@context)
    @context = Context.new(@root_context, file)
    @context.last_file_context = @last_file_context
    @last_file_context = @context
  end

  def enter_flow_control_block_scope()
    @context_queue.push(@context)
    @context = Context.new(@context, @context.current_self)
  end

  def enter_method_scope(receiver)
    @context_queue.push(@context)
    @context = Context.new(base_scope, receiver)
    @context.last_method_context = @last_method_context
    @last_method_context = @context
  end

  def enter_class_definition_scope(daisy_class)
    @context_queue.push(@context)
    @context = Context.new(@context, daisy_class, daisy_class)
    @context.defining_class = daisy_class
    @context
  end

  def enter_contract_definition_scope(contract)
    @context_queue.push(@context)
    @context = Context.new(@context, contract, contract)
  end

  def leave_scope(context)
    raise "Leaving scope with inactive context" if !context.nil? && context != @context
    @last_file_context = @context.last_file_context if !@context.last_file_context.nil?
    @last_method_context = @context.last_method_context if !@context.last_method_context.nil?
    @context = @context_queue.pop()
  end

  private
    def base_scope
      return @last_file_context if !@last_file_context.nil?
      @root_context
    end
end

