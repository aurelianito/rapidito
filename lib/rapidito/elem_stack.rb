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
  class ElemStack
    def initialize
      @data = []
    end
    
    def any?( &block )
      @data.any?( &block )
    end
    
    def count
      @data.count
    end
    
    def empty?
      @data.empty?
    end
    
    def push( elem, extra = {})
      @data << [elem,extra]
    end
    
    def pop
      @data.pop
    end
    
    def last_elem
      last[0]
    end
    
    def last_extra
      last[1]
    end
    
    def last
      @data.last
    end
    
    def deep_clone
      Marshal.load(Marshal.dump(self))
    end
    
    def close_elems( rules )
      rules[ :until_top ] ||= proc { self.empty? }
      rules[ :keep_unless ] ||= proc { false }
      
      elems_kept = ElemStack.new
      until rules[ :until_top ][self.last_elem, self.last_extra]
        popped_elem, popped_extra = self.pop
        self.last_elem << popped_elem
        elems_kept.push( popped_elem.similar, popped_extra ) \
          unless rules[ :keep_unless ][popped_elem, popped_extra]
      end
      elems_kept
    end
  end
end