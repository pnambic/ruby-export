require_relative "analyze_bytecode"
require_relative "graph_builder"
require_relative "../graph/graph"
require_relative "../graph/node_ruby"
require_relative "../graph/relation_ruby"

class AnalyzeMethod

  def analyze
    site = @method_node.site
    @builder.logger.info "METHOD: #{site}"

    iseq = RubyVM::InstructionSequence.of(site)
    return if iseq.nil?

    byte_info = AnalyzeBytecode.new(@builder, self, iseq)
    byte_info.analyze()
  end

  def lookup_receiver(sym)
    site = @method_node.site
    scope = site.owner
    result = lookup_scope_receiver(scope, sym)
    return result unless result.nil?

    @type.lookup_receiver(sym)
  end

  def add_dest_depend(dest_node, relation)
    @builder.add_depend(@method_node, dest_node, relation)
  end

  def initialize(builder, type, method_node)
    @builder = builder
    @type = type
    @method_node = method_node
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
