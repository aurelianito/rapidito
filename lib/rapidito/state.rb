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