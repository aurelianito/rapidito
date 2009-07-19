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

require 'rapidito/state'
require 'rapidito/processors'
require 'rapidito/nodes' 
require 'rapidito/verbatim_state'

module Rapidito
  
  class BlockState < State
    def initialize( rapidito, non_escaped_rules )
      super( rapidito.formatting_rules )
      formatting_tokens = self.delimiters
      self.add_rules( non_escaped_rules )
      non_escaped_tokens = self.delimiters - formatting_tokens
      self.add_rule( 
        "!", 
        StateProcessor.new {EscapeState.new("!", formatting_tokens, non_escaped_tokens)}
      )
    end
  end
  
  class EscapeState < State
    def initialize( escape, escapables, abort_tokens )
      super(
        escape => proc do
          |st|
          st.stack.push( TextNode.new( st.token.to_s * 2 ) )
          :finish_state
        end,
        escapables => proc do
          |st|
          st.stack.push( TextNode.new( st.token.to_s ) )
          :finish_state
        end,
        abort_tokens => proc do
          |st|
          st.stack.push( TextNode.new( escape ) )
          st.tokenizer.source = st.token.to_s + st.tokenizer.source
          :finish_state
        end,
        :text => proc do
          |st|
          st.stack.push( TextNode.new( escape + st.token.to_s ) )
          :finish_state
        end,
        :empty_source => proc do
          |st|
          st.stack.push( TextNode.new( escape ) )
          :finish_state
        end
      )
    end
  end
end