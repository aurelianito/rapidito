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
require 'rack/test'
require 'app'

class StartTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  def teardown
    Page.delete_all
  end

  def test_fill_start_page
    get '/'
    follow_redirect!
    
    assert_equal "http://example.org/Start", last_request.url
    assert last_response.body.include? 'Describe Start here'
    
    get '/Start/edit'
    assert last_response.body.include? 'Describe Start here'
    
    post '/Start/save', :markup => "Start page markup"
    follow_redirect!
    assert_equal "http://example.org/Start", last_request.url
    assert last_response.body.include? "Start page markup"
  end

end