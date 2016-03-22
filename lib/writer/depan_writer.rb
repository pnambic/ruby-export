require 'builder'

class DepanWriter

  def export
    markup = Builder::XmlMarkup.new(:indent=>2)
    markup.instruct!
    markup.tag!('graph-info') {
      markup.graphAnalyzers {
        # Analyzer zero is "default", so make Ruby first.
        markup.tag!('src-analyzer','com.google.devtools.depan.ruby')
        markup.tag!('src-analyzer','com.google.devtools.depan.filesystem')
        markup.tag!('src-analyzer','com.google.devtools.depan')
      }
      markup.graph {
        @builder.nodes.each do |id, node|
          node.as_xml(markup)
        end
        @builder.edges.each do |id, edge|
          markup.tag!('graph-edge') do
            edge.relation.as_xml(markup)
            markup.head edge.head.ruby_id
            markup.tail edge.tail.ruby_id
          end
        end
      }
    }
    @out_file.write(markup.target!)
  end

  def initialize(out_file, builder)
    @out_file = out_file
    @builder = builder
  end
end
