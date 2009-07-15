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