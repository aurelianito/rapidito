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