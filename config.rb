%w{ rubygems sinatra activerecord }.each do
  |lib|
  require lib
end

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

configure :development do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'development.sqlite3'
  )
end

configure :test do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => ':memory:'
  )
end

Dir.glob( "model/*.rb" ).each do
  |m|
  require m
end