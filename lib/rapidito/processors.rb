=begin AFFERO_3
rapidito. Wiki database.
Copyright (C) 2009 Aureliano Calvo.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

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