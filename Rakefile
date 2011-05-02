require "rubygems"
require "bundler/setup"

require 'active_record'
require 'sqlite3'
require 'yaml'

namespace :fake_data do
  namespace :db do 
    desc "Migrate the database using scripts in db/migrate."
    task :migrate => :enviroment do
      ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
    end

    task :enviroment do
      ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml')))
      #ActiveRecord::Base.logger = Logger.new(File.open('log/database.log','a'))
    end
  end
end
