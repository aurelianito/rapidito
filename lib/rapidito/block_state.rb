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