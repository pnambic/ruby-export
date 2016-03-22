require 'minitest/autorun'

require_relative '../../lib/analyze/analyze_class'
require_relative '../../lib/analyze/graph_builder'

require_relative 'class_simple'
require_relative 'class_class_method'

class AnalyzeClassTest < Minitest::Test
  def test_analyze_simple
    builder = GraphBuilder.new(Logger.new(STDERR))
    test = AnalyzeClass.new(builder, ClassSimple)
    test.analyze

    # Class, ClassSimple, ClassSimple.simple
    assert_equal(3, builder.nodes.size)
    assert_equal(2, builder.edges.size)
  end

  def test_analyze_class_method
    builder = GraphBuilder.new(Logger.new(STDERR))
    test = AnalyzeClass.new(builder, ClassClassMethod)
    test.analyze

    # Class, ClassSimple, Class:ClassSimple.class_method
    assert_equal(3, builder.nodes.size)
    assert_equal(2, builder.edges.size)
  end
end
