require 'rapidito/nodes'

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
end