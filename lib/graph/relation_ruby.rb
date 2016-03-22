require_relative "graph"

class RubyRelation < Relation

  def self.as_xml(markup)
    markup.relation(
      enum_label,
      :class=>'ruby-relation')
  end
end

class RubyExtendsType < RubyRelation
  def self.enum_label; 'EXTENDS_TYPE' end
end

class RubyClassMethodMember < RubyRelation
  def self.enum_label; 'CLASS_MEMBER' end
end

class RubyInstanceMethodMember < RubyRelation
  def self.enum_label; 'INSTANCE_MEMBER' end
end

class RubySingletonMethodMember < RubyRelation
  def self.enum_label; 'SINGLETON_MEMBER' end
end
