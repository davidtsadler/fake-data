require "rubygems"
require "bundler/setup"

require 'active_record'
require 'sqlite3'
require 'yaml'
require 'logger'

module FakeData
  class Base
    ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml')))
    ActiveRecord::Base.logger = Logger.new(File.open('log/database.log','a'))
  end
end
