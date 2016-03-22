require_relative 'graph'

class RubyNode < Node
  def ruby_id
    "ruby:#{ruby_label}"
  end
end

class RubyClass < RubyNode
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def as_xml(markup)
    markup.tag!("ruby-class") {
      markup.type(@type)
    }
  end

  def ruby_label
    "#{@type}"
  end

  def ==(other)
    self.type == other.type
  end
  alias :eql? :==

  def hash
    @type.hash
  end
end

class RubyMethod < RubyNode
  attr_reader :type
  attr_reader :method

  def initialize(type, method)
    @type = type
    @method = method
  end

  def as_xml_tag(markup, tag)
    markup.tag!(tag) {
      # Force names to not be ::Symbol.
      markup.tag!('type', @type.name.to_s)
      markup.tag!('method', @method.name.to_s)
    }
  end

  def ==(other)
    self.type == other.type &&
    self.method == other.method
  end
  alias :eql? :==

  def hash
    [@type, @method].hash
  end
end

class RubyClassMethod < RubyMethod

  def initialize(type, method)
    super type, method
  end

  def as_xml(markup)
    as_xml_tag(markup, "ruby-class_method")
  end

  def ruby_label
    "#{@type.name}::#{@method.name}"
  end
end

class RubyInstanceMethod < RubyMethod

  def initialize(type, method)
    super type, method
  end

  def as_xml(markup)
    as_xml_tag(markup, "ruby-instance_method")
  end

  def ruby_label
    "#{@type.name}.#{@method.name}"
  end
end

class RubySingletonMethod < RubyMethod

  def initialize(type, method)
    super type, method
  end

  def as_xml(markup)
    as_xml_tag(markup, "ruby-singleton_method")
  end

  def ruby_label
    "#{@type.name}.#{@method.name}"
  end
end
