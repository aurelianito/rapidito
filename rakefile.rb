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

desc "Run all tests"
task :default => :test

[
  {:name => :test, :desc => "All tests", :files => "test/**/*.rb" },
  {:name => "test:lib", :desc => "Library tests", :files => "test/lib/*.rb" },
  {:name => "test:model", :desc => "Model tests", :files => "test/model/*.rb" },
].each do
  |test|
  desc test[:desc]
  task test[:name] => :environment do
    ENV["RACK_ENV"] = "test"
    Dir[test[:files]].sort.each { |file| load file }
  end
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("migration")
    Rake::Task["db:dump_schema"].invoke
  end

  task :dump_schema => :environment do
    File.open("migration/schema.rb", "w") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end
  
  desc "Generate the initial pages for the wiki"
  task :initial => :environment do
    FileList.new("initial_pages/*").each do
      |file|
      name = file.split("/").last
      markup = File.read( file )
      Page.create_or_update( name, markup )
    end
    Page.create_or_update( "license", "\n{{{\n" + File.read( "LICENSE" ) + "\n}}}\n" )
    Page.create_or_update( "README", File.read( "README" ) )
  end
end

task :environment do
  require 'config'
end

LICENSE_INFO = <<LICENSE
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
LICENSE

task :license do
  FileList["**/*.rb"].each do
    |fname|
    source = File.read(fname)
    unless source.start_with? LICENSE_INFO 
      File.open( fname, "w") do
        |f|
        f.write( LICENSE_INFO + "\n" + source )
      end
    end
  end
end

