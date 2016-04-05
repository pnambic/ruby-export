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

  # Type Class
  attr_reader :type

  # Type Method
  attr_reader :site

  def initialize(type, site)
    @type = type
    @site = site
  end

  def as_xml_tag(markup, tag)
    markup.tag!(tag) {
      # Force names to not be ::Symbol.
      markup.tag!('type', @type.name.to_s)
      markup.tag!('method', @site.name.to_s)
    }
  end

  def ==(other)
    self.type == other.type &&
    self.site == other.site
  end
  alias :eql? :==

  def hash
    [@type, @site].hash
  end
end

class RubyClassMethod < RubyMethod

  def initialize(type, site)
    super type, site
  end

  def as_xml(markup)
    as_xml_tag(markup, "ruby-class_method")
  end

  def ruby_label
    "#{@type.name}::#{@site.name}"
  end
end

class RubyInstanceMethod < RubyMethod

  def initialize(type, site)
    super type, site
  end

  def as_xml(markup)
    as_xml_tag(markup, "ruby-instance_method")
  end

  def ruby_label
    "#{@type.name}.#{@site.name}"
  end
end

class RubySingletonMethod < RubyMethod

  def initialize(type, site)
    super type, site
  end

  def as_xml(markup)
    as_xml_tag(markup, "ruby-singleton_method")
  end

  def ruby_label
    "#{@type.name}.#{@site.name}"
  end
end
