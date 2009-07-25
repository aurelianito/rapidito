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