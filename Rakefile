# Add lib directory to load path so that statements like require 'artist' work.
$: << File.expand_path(File.dirname(__FILE__)) + "/lib"

require "rubygems"
require "bundler/setup"

require 'active_record'
require 'sqlite3'
require 'yaml'
require 'logger'

require 'artist'

namespace :fake_data do
  namespace :db do 
    desc "Migrate the database using scripts in db/migrate."
    task :migrate => :enviroment do
      ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
    end

    task :enviroment do
      ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml')))
      ActiveRecord::Base.logger = Logger.new(File.open('log/database.log','a'))
    end

    desc "Rebuilds and populates database with fake data."
    task :populate => [:destroy_data] do
    end

    desc "Destroys all the data in the database."
    task :destroy_data do
      Artist.destroy_all
    end
  end
end
