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
require 'uri'

module Rapidito
  class LinkProcessor
    
    # \303[\200-\277] are the acentuated chars like Á or ñ
    REGEX = /([A-Za-z0-9]|\303[\200-\277])*(_([A-Za-z0-9]|\303[\200-\277])+)+/
    
    def initialize( base_url )
      @base_url = base_url
    end
      
    def call( st )
      page = st.token.to_s
      page = page[1, page.length] if page[0,1] == "_"
      link = HtmlElem.new( :a, :href => @base_url + page )
      link << TextNode.new( page.gsub("_", " " ) )
      st.stack.last_elem << link
    end
  end
  
  class ExternalLinkProcessor
    #little hack because URI.regexp is frozen and the lang_hacks require the regexp to be non-frozen
    REGEX = Regexp.new( URI.regexp ) 
    
    def call( st )
      page = st.token.to_s
      link = HtmlElem.new( :a, :href => page )
      link << TextNode.new( page )
      st.stack.last_elem << link
    end
  end
end