require "rubygems"
require "bundler/setup"

require 'active_record'
require 'sqlite3'
require 'yaml'
require 'logger'

module FakeData
  ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml')))
  ActiveRecord::Base.logger = Logger.new(File.open('log/database.log','a'))

  module HamlTemplate
    def load_haml_template(filename)
      template = File.read(File.join('templates/haml',filename + '.haml'))
      Haml::Engine.new(template, :escape_html => true, :ugly => true)
    end
  end

  module Random
    def random_price(value = 1..100)
      "#{random_value(value)}.#{random_value(1..99)}"
    end

    def random_value(value)
      case value
      when Array then value[rand(value.size)]
      when Range then value_in_range(value)
      else value
      end
    end

    def value_in_range(range)
      case range.first
      when Integer then number_in_range(range)
      else range.to_a[rand(range.to_a.size)]
      end
    end

    def number_in_range(range)
      if range.exclude_end?
        rand(range.last - range.first) + range.first
      else
        rand((range.last+1) - range.first) + range.first
      end
    end
  end
end
