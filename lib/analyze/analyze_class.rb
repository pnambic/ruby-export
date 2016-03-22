require_relative "graph_builder"
require_relative "analyze_method"
require_relative "../graph/graph"
require_relative "../graph/node_ruby"
require_relative "../graph/relation_ruby"

class AnalyzeClass

  def analyze
    @builder.logger.info "Analyzing class #{@type}"
    @type_node = RubyClass.new(@type)
    super_node = RubyClass.new(@type.class)

    if @builder.nodes[super_node].nil?
      @builder.add_for_analysis(@type.class)
    end
    @builder.add_depend(super_node, @type_node, RubyExtendsType)

    @type.instance_methods.each do |sym|
      method = @type.instance_method(sym)
      next unless method.owner == @type

      analyze_method(method, RubyInstanceMethod, RubyInstanceMethodMember)
    end

    @type.singleton_methods.each do |sym|
      method = @type.method(sym)
      analyze_method(method, RubyClassMethod, RubyClassMethodMember)
    end
  end

  def lookup_receiver(receiver)
    result = lookup_scope_receiver(@type, receiver)
    return result unless result.nil?

    @builder.logger.info "Kernel lookup #{receiver}"
    lookup_scope_receiver(Kernel, receiver)
  end

  def initialize(builder, type)
    @builder = builder
    @type = type
  end

  private

  def analyze_method(method, kind, relation)
    method_node = kind.new @type, method
    @builder.add_depend(@type_node, method_node, relation)

    analyzer = AnalyzeMethod.new(@builder, self, method)
    analyzer.analyze
  end

  def lookup_scope_receiver(scope, rcvr_sym)
    begin
      scope.const_get(rcvr_sym, true)
    rescue NameError
      nil
    end
  end
end
