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
        link( :rel => "shortcut icon", :type => "image/png", :href => "/favicon.png?#{rand}" )

      end
      body { self.instance_eval( &content ) }
    end
  end
end

get '/' do
  redirect '/Start'
end

get '/:page' do
  page_name = params[:page]
  page = Page.find_by_name_or_new( page_name.upcase, "Describe #{page_name} here" )
  
  full_page( page_name ) do
    Rapidito::Rapidito.new('/').parse( page.markup ).to_html +
    hr +
    form( :action => "/#{page_name}/edit", :method => :get ) do
      input( :type => :submit, :value => "Edit" )
    end
  end
end

get '/:page/edit' do
  page_name = params[:page]
  page = Page.find_by_name_or_new( page_name.upcase, "Describe #{page_name} here" )
    
  full_page( "Edit #{page_name}" ) do
    form( :action => "/#{page_name}/save", :method => :post ) do
      div { textarea( page.markup, :name => :markup ) }
      input( :type => :submit, :value => "Save" )
    end
  end
end

post '/:page/save' do
  page_name = params[:page]
  Page.create_or_update( page_name.upcase, params[:markup] )
  redirect "/#{page_name}"
end