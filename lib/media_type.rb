require 'fake_data'

class MediaType < ActiveRecord::Base
	has_and_belongs_to_many :media_locations

	validates_presence_of :name
	validates_uniqueness_of :name
end
