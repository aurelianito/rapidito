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

require 'config'
require 'rapidito'
require 'lang_hacks'

def mab( &block )
  Markaby::Builder.new( &block ).to_s
end

def full_page( page_title, &content )
  mab do
    html do
      head do 
        title page_title 
        link( :rel => "stylesheet", :type => "text/css", :href => "/css/rapidito.css" )
        link( :rel => "shortcut icon", :type => "image/png", :href => "/favicon.ico?#{rand}" )

      end
      body do 
        div.header! do
          img.logo( :src => "/logo.png" )
        end
        div.body! do
          self.instance_eval( &content ) 
        end
      end
    end
  end
end

get '/' do
  redirect '/Start'
end

get '/:page' do
  page_name = params[:page]
  page = Page.find_by_name_or_new( page_name, "Describe #{page_name} here" )
  
  full_page( page_name ) do
    Rapidito::Rapidito.new('/').parse( page.markup ).to_html +
    form( :action => "/#{page_name}/edit", :method => :get ) do
      input( :type => :submit, :value => "Edit" )
    end
  end
end

get '/:page/edit' do
  page_name = params[:page]
  page = Page.find_by_name_or_new( page_name, "Describe #{page_name} here" )
    
  full_page( "Edit #{page_name}" ) do
    form( :action => "/#{page_name}/save", :method => :post ) do
      div { textarea( page.markup, :name => :markup ) }
      input( :type => :submit, :value => "Save" )
    end
  end
end

post '/:page/save' do
  page_name = params[:page]
  Page.create_or_update( page_name, params[:markup] )
  redirect "/#{page_name}"
end