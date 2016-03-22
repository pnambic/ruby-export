require 'minitest/autorun'

require_relative '../../lib/analyze/analyze_method'
require_relative '../../lib/analyze/graph_builder'

require_relative 'class_simple'

class AnalyzeMethodTest < Minitest::Test

  def test_analyze_simple
    builder = GraphBuilder.new(Logger.new(STDERR))
    method = ClassSimple.instance_method(:simple)
    test = AnalyzeMethod.new(builder, ClassSimple, method)
    test.analyze
  end
end
