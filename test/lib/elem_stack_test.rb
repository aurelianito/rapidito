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

require 'test/unit'
require 'rapidito/nodes'
require 'rapidito/elem_stack'

include Rapidito

class TestElemStack < Test::Unit::TestCase
  def setup
    @elem_stack = ElemStack.new
    @level0 = HtmlElem.new( :div )
    @level1 = HtmlElem.new( :b )
    @level2 = HtmlElem.new( :i )
    
    @elem_stack.push( @level0 )
    @elem_stack.push( @level1 )
    @elem_stack.push( @level2 )

  end
  
  def test_deep_clone
    cloned = @elem_stack.deep_clone
    popped2 = cloned.pop[0]
    popped1 = cloned.pop[0]
    assert_equal @level2, popped2
    assert_equal @level1, popped1
    assert_not_same @level2, popped2
    assert_not_same @level1, popped1
  end
  
  def test_close_elems
    kept = @elem_stack.close_elems(
      :until_top => proc { |elem, extra| elem.tag == :div },
      :keep_unless => proc { |elem, extra| elem.tag == :b }
    )
    
    assert_same @level0, @elem_stack.last_elem
    assert_equal 1, kept.count
    
    # the tag should be similar but not the same
    assert_equal :i, kept.last_elem.tag
    assert_not_same @level2, kept.last_elem.tag 
  end
end