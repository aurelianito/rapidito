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

class PagesTest < Test::Unit::TestCase

  def setup
  end
  
  def teardown
    Page.delete_all
  end
  
  def test_create_or_update
    Page.create_or_update( "NAME", "markup")
    Page.create_or_update( "name", "other markup")
    
    page_in_db = Page.find_by_name_or_new( "NaMe", "yet another markup" )
    
    assert_equal "NAME", page_in_db.name
    assert_equal "other markup", page_in_db.markup
    
    assert_equal 1, Page.count
    
  end
end