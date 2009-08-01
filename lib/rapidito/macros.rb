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

module Rapidito
  class MacroProcessor
    REGEX = /\[\[([A-Za-z_]+)\]\]/
    
    def initialize( rapidito )
      @rapidito = rapidito
    end
    
    def call(st)
      macro_name = st.token[1]
      html_elem = 
        if @rapidito.macros.include?(macro_name)
          @rapidito.macros[macro_name].call
        else
          TextNode.new( st.token.to_s )
        end
        
      st.stack.last_elem << html_elem
    end
  end
end