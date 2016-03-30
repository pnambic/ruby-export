require 'minitest/autorun'
require 'logger'

require_relative '../../lib/analyze/analyze_method'
require_relative '../../lib/analyze/graph_builder'
require_relative '../../lib/analyze/graph_builder'

require_relative 'class_simple'

class AnalyzeMethodTest < Minitest::Test

  def test_analyze_simple
    builder = GraphBuilder.new(Logger.new(STDERR))
    site = ClassSimple.instance_method(:simple)
    method_node = RubyInstanceMethod.new(ClassSimple, site)
    test = AnalyzeMethod.new(builder, nil, method_node)
    test.analyze
  end
end
