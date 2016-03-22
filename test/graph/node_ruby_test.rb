require 'minitest/autorun'
require 'builder'

require_relative '../../lib/graph/node_ruby'

class NodeRubyTest < Minitest::Test

  # Class nodes
  def test_ruby_class_new
    node = RubyClass.new(TestClass)
    assert_equal('TestClass', node.ruby_label())
  end

  def test_ruby_class_xml
    node = RubyClass.new(TestClass)
    markup = Builder::XmlMarkup.new()

    assert_equal(
      '<ruby-class><type>TestClass</type></ruby-class>',
      node.as_xml(markup))
  end

  # Class method nodes
  def test_ruby_class_method_new
    method = TestClass.method(:class_method)
    node = RubyClassMethod.new(TestClass, method)
    assert_equal('TestClass::class_method', node.ruby_label)
  end

  def test_ruby_class_method_xml
    method = TestClass.method(:class_method)
    node = RubyClassMethod.new(TestClass, method)
    assert_markup(node, 'class_method', 'TestClass', 'class_method')
  end

  # Instance method nodes
  def test_ruby_instance_method_new
    method = TestClass.instance_method(:instance_method)
    node = RubyInstanceMethod.new(TestClass, method)
    assert_equal('TestClass.instance_method', node.ruby_label)
  end

  def test_ruby_instance_method_xml
    method = TestClass.instance_method(:instance_method)
    node = RubyInstanceMethod.new(TestClass, method)
    assert_markup(node, 'instance_method', 'TestClass', 'instance_method')
  end

  # Singleton method nodes
  def test_ruby_singleton_method_new
    method = TestClass.singleton_method(:class_method)
    node = RubySingletonMethod.new(TestClass, method)
    assert_equal('TestClass.class_method', node.ruby_label)
  end

  def test_ruby_singleton_method_xml
    method = TestClass.singleton_method(:class_method)
    node = RubySingletonMethod.new(TestClass, method)

    markup = Builder::XmlMarkup.new()
    assert_equal(
      '<ruby-singleton_method><type>TestClass</type><method>class_method</method></ruby-singleton_method>',
      node.as_xml(markup))

  end

  private

  def assert_markup(node, container, type, name)
    expect = "<ruby-#{container}><type>#{type}</type><method>#{name}</method></ruby-#{container}>"

    markup = Builder::XmlMarkup.new()
    assert_equal(expect, node.as_xml(markup))

  end
end

class TestClass

  def self.class_method
  end

  def instance_method
  end
end