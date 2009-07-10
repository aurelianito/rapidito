class Page < ActiveRecord::Base
  def self.find_by_name_or_new( name, markup )
    self.find_by_name( name ) || self.new( :name => name, :markup => markup )
  end
  def self.create_or_update( name, markup )
    page = self.find_by_name( name ) || self.new( :name => name )
    page.markup = markup
    page.save!
  end
end