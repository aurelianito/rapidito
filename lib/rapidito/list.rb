require 'rapidito/block_state'
require 'rapidito/nodes'
require 'rapidito/elem_stack'

module Rapidito
  
  class ListState < BlockState
  
    def self.list_starters(preamble="")
      preamble = Regexp.escape(preamble)
      [ 
        /#{preamble} +[1-9]\d*\. /, 
        /#{preamble} +[*-] /,
        /#{preamble} +[a-zA-Z] /,
        /#{preamble} +[iI]+\. /,
      ]
    end
    def initialize( rapidito, token )
    
      initial_depth = depth(token)
      list_tag = list_tag(token)
      
      super(
        rapidito,
        self.class.list_starters("\n") => proc { |st| st.new_list_item(st.token) },
        /\n/ => proc { :finish_state }
      )
      
      self.stack.push( HtmlElem.new( list_tag, options(token) ) )
      self.stack.push( HtmlElem.new( :li ), :depth => initial_depth, :list_tag => list_tag )
    end
    
    def depth( token )
      depth = -1
      token.to_s.each_char { |ch| depth += 1 if ch==" " }
      depth
    end
    
    def list_tag( token )
      token.to_s[-2,1] == "." ? :ol : :ul
    end
    
    def options( token )
      return {} unless list_tag(token) == :ol
      
      head = token.to_s.strip.chomp(".")
      case head
      when /^1$/:
        {}
      when /^\d+$/:
        {:start => head}
      when /^i+$/:
        {:class => :lower_roman}
      when /^I+$/:
        {:class => :upper_roman}
      when /^[a-z]$/:
        {:class => :lower_letter}
      when /^[A-Z]$/:
        {:class => :upper_letter}
      else
        {}
      end
    end
    
    def new_list_item( token )
      depth = depth( token )
      list_tag = list_tag( token )
      
      list_removed = false
      
      elems_kept = stack.close_elems(
        :until_top => proc do
          |elem, extra|
          stack.count == 1 || # main list reached
          ( elem.tag == :li &&
            ( extra[:depth] < depth || 
            ( extra[:depth] == depth && extra[:list_tag] == list_tag ) ) ) 
        end,
        :keep_unless => proc do 
          |elem, extra| 
          list_removed = true if [:ul, :ol].include? elem.tag
          
          [:li,:ul, :ol].include? elem.tag 
        end
      )
      
      if stack.count == 1 # main list reached
        tokenizer.source = token.to_s + tokenizer.source
        return :finish_state
      end
      
      last_extra = stack.last_extra
      if last_extra[:list_tag] == list_tag && 
        (list_removed || last_extra[:depth] == depth)
        li = stack.pop[0]
        stack.last_elem << li
      else 
        stack.push( HtmlElem.new( list_tag, options(token) ) )
      end
      
      stack.push( HtmlElem.new( :li ), :depth => depth, :list_tag => list_tag )
      stack.push( *elems_kept.pop ) until elems_kept.empty?
    end
  end
end