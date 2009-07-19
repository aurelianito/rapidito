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

%w{ rubygems sinatra activerecord }.each do
  |lib|
  require lib
end

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

%w{ lang_hacks rapidito }.each do
  |lib|
  require lib
end


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