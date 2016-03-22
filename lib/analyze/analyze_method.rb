require_relative "analyze_bytecode"
require_relative "graph_builder"
require_relative "../graph/graph"
require_relative "../graph/node_ruby"
require_relative "../graph/relation_ruby"

class AnalyzeMethod

  def analyze
    @builder.logger.info "METHOD: #{@method}"

    iseq = RubyVM::InstructionSequence.of(@method)
    return if iseq.nil?

    byte_info = AnalyzeBytecode.new(@builder, self, iseq)
    byte_info.analyze()
  end

  def lookup_receiver(sym)
    scope = @method.owner
    result = lookup_scope_receiver(scope, sym)
    return result unless result.nil?

    @type.lookup_receiver(sym)
  end

  def initialize(builder, type, method)
    @builder = builder
    @type = type
    @method = method
  end

  private

  def lookup_scope_receiver(scope, rcvr_sym)
    begin
      scope.const_get(rcvr_sym, true)
    rescue NameError
      nil
    end
  end
end
