require_relative "../graph/graph"
require_relative "../graph/node_ruby"
require_relative "../graph/relation_ruby"

class GraphBuilder
  attr_reader :logger
  attr_reader :nodes
  attr_reader :edges

  def initialize(logger)
    @logger = logger
    @nodes = {}
    @edges = {}
    @seen = {}
    @deps = []
  end

  def add_depend(head, tail, relation)
    headNode = get_node(head)
    tailNode = get_node(tail)
    edge = Edge.new(headNode, tailNode, relation)
    @edges[edge] = edge
  end

  def get_node(node)
    result = @nodes[node]
    return result unless result.nil?
    logger.info "Adding #{node.ruby_id}"
    @nodes[node] = node
    return node
  end

  def read_deps
    result = @deps
    @deps = []
    return result
  end

  def add_for_analysis(type)
    return unless addable?(type)
    return if @seen[type]
    @seen[type] = type
    @deps << type
  end

  private

  def addable?(type)
    return true if type.is_a?(Class)
    return true if type.is_a?(Module)
    false
  end
end
