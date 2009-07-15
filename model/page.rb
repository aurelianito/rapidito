class Page < ActiveRecord::Base
  def self.find_by_name_or_new( name, markup )
    self.find_by_name( name.upcase ) || self.new( :name => name.upcase, :markup => markup )
  end
  def self.create_or_update( name, markup )
    page = self.find_by_name( name.upcase ) || self.new( :name => name.upcase )
    page.markup = markup
    page.save!
  end
end