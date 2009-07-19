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