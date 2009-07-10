require 'test/unit'
require 'rapidito/nodes'

class TestNodes < Test::Unit::TestCase
  def test_text_node_equality
    aaa1 = TextNode.new "aaa"
    aaa2 = TextNode.new "aaa"
    bbb = TextNode.new "bbb"
    
    assert( aaa1 == aaa2 )
    assert( aaa1 != bbb )
  end
  
  def test_html_elem_equality
    child = TextNode.new "child"
    div1 = HtmlElem.new( :div )
    div2 = HtmlElem.new( :div )
    div_with_klass = HtmlElem.new( :div, :class => "klass" )
    paragraph = HtmlElem.new( :p )
    
    assert( div1 != div_with_klass )
    assert( div1 != paragraph )
    assert( div1 != child )
    
    assert( div1 == div2 )
    div1 << child
    assert( div1 != div2 )
    div2 << child
    assert( div1 == div2 )
  end
end