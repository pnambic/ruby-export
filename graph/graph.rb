#!/usr/bin/ruby
class Node

end

class Relation

end

class Edge
  attr_reader :head
  attr_reader :tail
  attr_reader :relation

  def initialize(head, tail, relation)
    @head = head
    @tail = tail
    @relation = relation
  end
end

class Graph
  attr_reader :nodes
  attr_reader :edges

  def initialize(nodes, edges)
    @nodes = nodes
    @edges = edges
  end
end