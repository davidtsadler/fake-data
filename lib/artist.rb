require 'fake_data'

class Artist < ActiveRecord::Base
  validates :name, :presence => true,
                   :uniqueness => { :case_sensitive => false }

  has_and_belongs_to_many :albums
end
