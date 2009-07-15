require 'rapidito/tokenizer'
require 'rapidito/elem_stack'
require 'rapidito/nodes'
require 'rapidito/state'
require 'rapidito/processors'
require 'rapidito/list'
require 'rapidito/block_state'
require 'rapidito/links'

require 'lang_hacks'

module Rapidito
  class Rapidito
  
    attr_reader :formatting_rules
  
    def initialize( base_url )
      @formatting_rules = {
        "''" => ElemProcessor.new(:i),
        "'''" => ElemProcessor.new(:b),
        "__" => ElemProcessor.new(:u),
        "~~" => ElemProcessor.new(:del),
        "^" => ElemProcessor.new(:sup),
        ",," => ElemProcessor.new(:sub),
        "{{{" => StateProcessor.new {
          SingleLineVerbatimState.new( :tt, "{{{", "}}}" )
        },
        "`" => StateProcessor.new {
          SingleLineVerbatimState.new( :tt, "`", "`" )
        },
        LinkProcessor::REGEX => LinkProcessor.new( base_url ),
        :text => TextProcessor.new,
      }.freeze
    end
    
    def parse( source )
      MainState.new( self ).process( source.gsub( "\r", "" ) )
    end
  end
  
  class MainState < State
    def initialize( rapidito )
      heading_rules = {}
      (1..5).each do
        |i|
        heading_rules[/(={#{i}}) /] = StateProcessor.new { HeadingState.new(rapidito, i) }
      end
      super(
        {
          #ignore newlines
          /\n+/ => proc{}, 

          #normal paragraphs
          :text => StateProcessor.new( true ) { ParagraphState.new(rapidito) },
          
          ListState.list_starters => 
            StateProcessor.new { |st| ListState.new( rapidito, st.token ) },
            
          / +/ => StateProcessor.new { |st| BlockQuoteState.new( rapidito ) },
          
          DefinitionState::TOKEN =>
            StateProcessor.new { |st| DefinitionState.new( rapidito, st.token ) },
            
          "{{{\n" => 
            StateProcessor.new { 
              VerbatimState.new( :pre, "\n{{{\n", "\n}}}\n" )
            }
        }.merge!( heading_rules )
      )
      self.stack.push( HtmlElem.new(:div, :class => 'rapidito') )
    end
  end
  
  class HeadingState < BlockState
    attr_reader :root_node, :heading_number
    def initialize( rapidito, heading_number )
      super(
        rapidito,
        / ={#{heading_number}}(\n|\z)/ => proc do
          |st|
          st.root_node.tag = :"h#{st.heading_number}"
          :finish_state
        end,
        [/\n/, :empty_source] => proc do
          |st|
          st.root_node.tag = :p
          st.root_node.children.unshift TextNode.new("="*st.heading_number + " ")
          :finish_state
        end
      )
      
      @heading_number = heading_number
      @root_node = HtmlElem.new
      self.stack.push @root_node
    end
  end
  
  class BlockQuoteState < BlockState
    def initialize( rapidito )
      super(
        rapidito,
        /\n/ => proc { :finish_state },
        ListState.list_starters => proc do 
          |st| 
          st.tokenizer.source = st.token.to_s + st.tokenizer.source
          :finish_state 
        end,
        /\n +/ => proc do 
          |st| 
          st.stack.last_elem << TextNode.new( " " ) 
        end
      )
      
      self.stack.push( HtmlElem.new( :blockquote ) )
      self.stack.push( HtmlElem.new( :p ) )
    end
  end
  
  class DefinitionState < State

    TOKEN = /(.+)::(.+)/
    def initialize( rapidito, initial_token )
      super(
        /\n/ => proc {},
        /\n +/ => proc do 
          |st| 
          st.stack.last_elem << TextNode.new( " " ) 
        end,
        TOKEN => proc {|st| new_value_pair(st.token)},
        :text => proc do
          |st| 
          st.tokenizer.source = st.token + st.tokenizer.source 
          :finish_state
        end
      )
      self.stack.push( DefinitionList.new )
      new_value_pair( initial_token )
    end
    
    def new_value_pair( token )
      self.stack.last_elem.new_definition( token[1], token[2] )
    end
  end
  
  class ParagraphState < BlockState
    def initialize( rapidito )
      super(
        rapidito,
        /\n{2}/ => proc { :finish_state },
        ListState.list_starters( "\n" ) + ["\n{{{\n"] => proc do
          |st|
          st.tokenizer.source = st.token.to_s + st.tokenizer.source
          :finish_state
        end
      )
      self.stack.push( HtmlElem.new( :p ) )
    end
  end
end