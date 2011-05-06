require 'fake_data'

class MediaLocation < ActiveRecord::Base
	has_and_belongs_to_many :media_types

	validates_presence_of :directory
	validates_uniqueness_of :directory
end
