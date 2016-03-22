require 'minitest/autorun'

require_relative '../../lib/analyze/analyze_bytecode'
require_relative '../../lib/analyze/graph_builder'
require 'logger'

require_relative 'class_simple'

class AnalyzeBytecodeTest < Minitest::Test
  def test_analyze_simple
    builder = GraphBuilder.new(Logger.new(STDERR))
    method = ClassSimple.instance_method(:simple)
    iseq = RubyVM::InstructionSequence.of(method)
    test = AnalyzeBytecode.new(builder, method, iseq)
    test.analyze
  end
end
