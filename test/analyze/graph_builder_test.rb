require 'minitest/autorun'

require_relative '../../lib/analyze/graph_builder'

require_relative '../../lib/graph/graph'
require_relative '../../lib/graph/node_ruby'
require_relative '../../lib/graph/relation_ruby'

class GraphBuilderTest < Minitest::Test
  def test_builder_new
    test = GraphBuilder.new(Logger.new(STDERR))
    assert_empty(test.nodes)
    assert_empty(test.edges)
    assert_empty(test.read_deps)
  end

  def test_add_depend
    test = GraphBuilder.new(Logger.new(STDERR))
    base_node = RubyClass.new(TestBase)
    derive_one_node = RubyClass.new(DeriveOne)
    derive_two_node = RubyClass.new(DeriveTwo)

    test.add_depend(base_node, derive_one_node, RubyExtendsType)
    test.add_depend(base_node, derive_two_node, RubyExtendsType)

    assert_equal(3, test.nodes.size)
    assert_equal(2, test.edges.size)
    assert_equal(0, test.read_deps.size)
  end

  def test_add_for_analysis
    test = GraphBuilder.new(Logger.new(STDERR))

    test.add_for_analysis(TestBase)
    test.add_for_analysis(TestBase)

    deps = test.read_deps
    assert_equal(1, deps.size)
    assert_equal(TestBase, deps[0])
    assert_equal(0, test.read_deps.size)

    test.add_for_analysis(TestBase)
    test.add_for_analysis(DeriveOne)
    test.add_for_analysis(DeriveTwo)

    deps = test.read_deps
    assert_equal(2, deps.size)
    assert(deps.include?(DeriveOne))
    assert(deps.include?(DeriveTwo))
  end
end

class TestBase
end

class DeriveOne < TestBase
  def simple
  end
end

class DeriveTwo < TestBase
  def simple
  end
end