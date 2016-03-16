#!/usr/bin/ruby
require_relative "../graph/graph"
require_relative "../graph/node_ruby"
require_relative "../graph/relation_ruby"

class GraphBuilder
  attr_reader :nodes
  attr_reader :edges
  attr_reader :deps

  def initialize
    @nodes = {}
    @edges = {}
    @deps = []
  end

  def add_depend(head, tail, relation)
    headNode = get_node(head)
    tailNode = get_node(tail)
    edge = Edge.new(headNode, tailNode, relation)
    # puts "New Edge: #{headNode.ruby_id} -- #{relation} -> #{tailNode.ruby_id}"
    @edges[edge] = edge
  end

  def get_node(node)
    result = @nodes[node]
    return result unless result.nil?
    # puts "New Node: #{node.ruby_id}"
    @nodes[node] = node
    return node
  end

  def read_deps
    result = @deps
    @deps = []
    return result
  end
end

class AnalyzeMethod
  attr_reader :method
  attr_reader :iseq
  attr_reader :builder

  def initialize(builder, method, iseq)
    @builder = builder
    @method = method
    @iseq = iseq
  end

  def analyze
  end
end

class AnalyzeClass
  attr_reader :type
  attr_reader :builder

  def initialize(builder, type)
    @builder = builder
    @type = type
  end

  def analyze_method(typeNode, sym, method, kind, relation)
    iseq = RubyVM::InstructionSequence.of(method)
    return if iseq.nil?

    methodNode = kind.new @type, sym
    builder.add_depend(typeNode, methodNode, relation)
    analyzer = AnalyzeMethod.new(@builder, method, iseq)
    analyzer.analyze
  end

  def analyze
    typeNode = RubyClass.new(@type)
    superNode = RubyClass.new(@type.class)

    if @builder.nodes[superNode].nil?
      @builder.deps << @type.class
    end
    builder.add_depend(superNode, typeNode, RubyExtendsType)

    type.methods.each do |sym|
      method = @type.method(sym)
      analyze_method(typeNode, sym, method, RubyClassMethod, RubyClassMethodMember)
    end

    type.instance_methods.each do |sym|
      method = @type.instance_method(sym)
      analyze_method(typeNode, sym, method, RubyInstanceMethod, RubyInstanceMethodMember)
    end

    type.singleton_methods.each do |sym|
      method = @type.method(sym)
      analyze_method(typeNode, sym, method, RubySingletonMethod, RubySingletonMethodMember)
    end
  end
end
