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