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
require 'rapidito/state'

include Rapidito

class StateTest < Test::Unit::TestCase
  def test_usage
    st = State.new(
      /finish/ => proc { |st| :finish_state },
      :text => proc { |st| st.stack.last_elem << TextNode.new( st.token ) },
      "p" => proc do 
        |st| 
        next_tok = st.tokenizer.next_token[0]
        elem = HtmlElem.new( :p )
        elem << TextNode.new( next_tok )
        st.stack.last_elem << elem
      end,
      [ "STR", /REGEX/ ] => proc { |st| st.stack.last_elem << TextNode.new( st.token.to_s + "ARY" ) }
    )
    
    st.stack.push( HtmlElem.new(:div) )
    assert_equal \
      "<div>start STRARY REGEXARY<p>inside</p></div>", 
      st.process( "start STR REGEXpinsidefinishoutside" ).to_html
    assert_equal "outside", st.tokenizer.source
  end
  
  def test_source_finished
    st = State.new(
      :empty_source => proc {|st| st.stack.last_elem << TextNode.new( "finished" ) } 
    )
    st.stack.push( HtmlElem.new(:p) )
    
    assert_equal "<p>finished</p>", st.process( "" ).to_html
  end
  
  def test_default_source_finished
    st = State.new( {} )
    st.stack.push( HtmlElem.new(:p) )
    assert_equal "<p></p>", st.process( "" ).to_html
  end
  
end
class SharedRulesStateTest < Test::Unit::TestCase
  def setup
    @st = State.new(
      [:text, :empty_source, /token/] => proc do 
        |st| 
        st.stack.last_elem << TextNode.new( "TEXT" )
        :finish_state
      end
    )
    @st.stack.push( HtmlElem.new(:p) )
  end
  def test_text
    assert_equal "<p>TEXT</p>", @st.process("Some text").to_html
  end
  def test_empty 
    assert_equal "<p>TEXT</p>", @st.process("").to_html
  end
  def test_token
    assert_equal "<p>TEXT</p>", @st.process("token").to_html
  end
end