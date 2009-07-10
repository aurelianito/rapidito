require 'rapidito/nodes'
require 'rapidito/elem_stack'

module Rapidito
  class ElemProcessor
    def initialize( tag )
      @tag = tag
    end
    def call( st )
      tok = st.token.to_s
      if st.stack.any? { |elem, extra| extra[:finisher] == tok }
        close_elem( st.stack, tok )
      else
        elem = HtmlElem.new(@tag)
        st.stack.push( elem, :finisher => tok )
      end
    end
    
    def close_elem( stack, finish_token )
      elems_kept = stack.close_elems(
        :until_top => proc { |el, ext| ext[:finisher] == finish_token }
      )
      
      popped_elem, popped_extra = stack.pop
      stack.last_elem << popped_elem
      
      stack.push( *elems_kept.pop ) until elems_kept.empty?
    end
  end
  
  class StateProcessor
    def initialize( use_last_token = false, &new_state_proc )
      @new_state_proc = new_state_proc
      @use_last_token = use_last_token
    end
    def call( st )
      new_st = @new_state_proc.call( st )
      response = new_st.process( 
        @use_last_token ? st.token.to_s + st.tokenizer.source : st.tokenizer.source 
      ) 
      st.stack.last_elem << response
      st.tokenizer.source = new_st.tokenizer.source
    end
  end
  
  class TextProcessor
    def call( st )
      st.stack.last_elem << TextNode.new( st.token )
    end
  end
end