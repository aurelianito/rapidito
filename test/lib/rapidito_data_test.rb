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

class RapiditoDataTest < Test::Unit::TestCase
  def test_data
    markup = <<MARKUP
== Something ==
key1::value1
key2::value2

And something else
MARKUP
    assert_equal(
      { "key1" => "value1", "key2" => "value2" },
      Rapidito::Rapidito.new("http://some_url/").parse(markup).data
    )
  end
end