require 'fake_data'

class Album < ActiveRecord::Base
  validates :name, :presence => true
  validates :uri, :presence => true,
                   :uniqueness => { :case_sensitive => false }

  has_and_belongs_to_many :artists
  has_many :tracks

  scope :with_cover, where('cover NOT NULL') 
end
