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
  class BaseLinkProcessor
    def call(st)
      url, text = link_data(st.token.to_s)
      link = HtmlElem.new( :a, :href => url )
      link << TextNode.new( text )
      st.stack.last_elem << link
    end
  end
  
  class LinkProcessor < BaseLinkProcessor
    
    # \303[\200-\277] are the acentuated chars like Á or ñ
    REGEX = /([A-Za-z0-9]|\303[\200-\277])*(_([A-Za-z0-9]|\303[\200-\277])+)+/
    
    def initialize( base_url )
      @base_url = base_url
    end
    
    def link_data( token )
      page = token.to_s
      page = page[1, page.length] if page[0,1] == "_"
      [ @base_url + page, page.gsub("_", " " ) ]
    end
      
  end
  
  class ExternalLinkProcessor < BaseLinkProcessor
    #little hack because URI.regexp is frozen and the lang_hacks require the regexp to be non-frozen
    REGEX = Regexp.new( URI.regexp(%w{http https ftp}) ) 
    
    def link_data( uri )
      [uri, uri]
    end
  end
end