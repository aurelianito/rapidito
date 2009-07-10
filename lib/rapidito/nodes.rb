require 'markaby'

module Rapidito
  class TextNode
    attr_reader :text
    def initialize( text )
      @text = text
    end
    
    def to_html
      Markaby::Builder.new.span( @text ).to_s.gsub(/<\/?span>/, "")
    end
    
    def ==( other )
      return false unless other.class == self.class
      self.text == other.text
    end
    
    def data
      {}
    end
  end
  
  class DefinitionList
    def initialize
      @definitions = []
    end
    def new_definition( key, value )
      @definitions << [key.strip, value.strip]
    end
    def to_html
      definitions = @definitions
      Markaby::Builder.new.dl do
        definitions.each do
          |key, value|
          dt key
          dd value
        end
      end
    end
    def data
      Hash[ *@definitions.flatten ]
    end
  end
  
  class HtmlElem
    attr_reader :children
    attr_accessor :tag, :attrs
    
    def initialize( tag=nil, attrs = {} )
      @tag, @attrs, @children = tag, attrs, []
    end
    
    def to_html
      children = @children
      Markaby::Builder.new.send( @tag, @attrs ) do
        children.map { |c| c.to_html }.join
      end
    end
    
    def <<( child )
      @children << child if child
    end
    
    def similar
      self.class.new( @tag, @attrs )
    end
    
    def data
      data = {}
      @children.each do
        |child|
        data.merge!( child.data )
      end
      data
    end
    
    def ==( other )
      return false unless other.class == self.class
      ( self.tag == other.tag ) && 
        ( self.attrs == other.attrs ) && 
        ( self.children == other.children )
    end
  end
end