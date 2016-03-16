#!/usr/bin/ruby
require 'builder'

class DepanWriter
  attr_reader :builder

  def initialize(builder)
    @builder = builder
  end

  def export
    markup = Builder::XmlMarkup.new(:indent=>2)
    markup.instruct!
    markup.tag!("graph-info") {
      markup.graphAnalyzers {
        markup.tag!("src-analyzer",'com.google.devtools.depan')
        markup.tag!("src-analyzer",'com.google.devtools.depan.filesystem')
        markup.tag!("src-analyzer",'com.google.devtools.depan.ruby')
      }
      markup.graph {
        @builder.nodes.each do |id, node|
          node.as_xml(markup)
        end
        @builder.edges.each do |id, edge|
          markup.tag!("graph-edge") {
            markup.relation edge.relation
            markup.head edge.head.ruby_id
            markup.tail edge.tail.ruby_id
          }
        end
      }
    }
    puts markup.target!
  end
end
