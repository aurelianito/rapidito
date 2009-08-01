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
require 'rapidito'

class RapiditoMacrosTest < Test::Unit::TestCase
  def assert_rapidito_paragraph( expected, markup )
    macros = {
      "SIMPLE_MACRO" => proc { TextNode.new("RESULT FROM MACRO") }
    }
    assert_equal "<div class=\"rapidito\"><p>#{expected}</p></div>", Rapidito::Rapidito.new("/",macros).parse(markup).to_html
  end
  
  
  def test_simple_macro
    assert_rapidito_paragraph \
      "Something before, RESULT FROM MACRO and something after",
      "Something before, [[SIMPLE_MACRO]] and something after"
  end
  
  def test_unknown_macro
    assert_rapidito_paragraph \
      "Something before, [[UNKNOWN_MACRO]] and something after",
      "Something before, [[UNKNOWN_MACRO]] and something after"
  end
end
