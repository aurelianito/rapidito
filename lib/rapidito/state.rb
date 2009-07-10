require 'rapidito/elem_stack'
require 'rapidito/tokenizer'
require 'rapidito/nodes'

module Rapidito
  class State
    #alterables
    attr_accessor :stack
    attr_writer :tokenizer
    
    #these should not be altered
    attr_reader :token, :rules
    
    def initialize( rules = {} )
      @rules = {:empty_source => proc {} } #do nothing on empty source by default
      @stack = ElemStack.new
      
      self.add_rules( rules )
    end
    
    def add_rules( rules )
      rules.each_pair do
        |descr, action|
        self.add_rule( descr, action )
      end
    end
    
    def add_rule( descriptor, action = nil, &block )
      action ||= block
      case descriptor
      when Regexp, Symbol
        @rules[ descriptor ] = action
      when Array
        descriptor.each { |item| add_rule( item, action ) }
      else
        @rules[ Regexp.compile( Regexp.escape( descriptor.to_s ) ) ] = action
      end
    end
    
    def tokenizer
      @tokenizer ||= Tokenizer.new( *self.delimiters )
    end
    
    def delimiters
      @rules.keys.select { |descr| Regexp === descr  }
    end
    
    def process( markup )
      self.tokenizer.source = markup
      end_unexpected = true
      
      while self.tokenizer.has_next?
        @token, kind = self.tokenizer.next_token
        end_unexpected = true
        if @rules[kind].call(self) == :finish_state
          end_unexpected = false
          break
        end
      end
      
      @rules[ :empty_source ].call(self) if end_unexpected
      
      while stack.count > 1
        child_elem, _ = stack.pop
        stack.last_elem << child_elem
      end
      
      return stack.last_elem
    end
  end
end