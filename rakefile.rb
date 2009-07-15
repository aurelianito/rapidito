desc "Run all tests"
task :default => :test

[
  {:name => :test, :desc => "All tests", :files => "test/**/*.rb" },
  {:name => "test:lib", :desc => "Library tests", :files => "test/lib/*.rb" },
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
  end
end

task :environment do
  require 'config'
end