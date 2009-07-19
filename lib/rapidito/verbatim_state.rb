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

module Rapidito
  class VerbatimState < State
    attr_accessor :depth
    def initialize( tag, opener, closer )
      super(
        opener => proc do 
          |st| 
          st.depth += 1
          st.stack.last_elem << TextNode.new( st.token )
        end,
        closer => proc do
          |st|
          st.depth -= 1
          if st.depth == 0 then
            :finish_state
          else
            st.stack.last_elem << TextNode.new( st.token )
          end
        end,
        :text => TextProcessor.new,
        :empty_source => proc do
          |st|
          text = st.stack.last_elem.children.inject( "" ) {|acum, child| acum + child.text}
          st.stack.pop
          st.stack.push( TextNode.new( opener ) )
          st.tokenizer.source = text 
          :finish_state
        end
      )
      self.depth = 1
      self.stack.push( HtmlElem.new( tag ) )
    end
  end
  
  class SingleLineVerbatimState < VerbatimState
    def initialize( tag, opener, closer )
      super( tag, opener, closer )
      self.add_rule( /\n/ ) do
        |st|
        text = st.stack.last_elem.children.inject( "" ) {|acum, child| acum + child.text}
        st.stack.pop
        st.stack.push( TextNode.new( opener ) )
        st.tokenizer.source = text + st.token.to_s + st.tokenizer.source
        :finish_state
      end
    end
  end
end