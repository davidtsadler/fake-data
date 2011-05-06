require 'fake_data'

class Track < ActiveRecord::Base
  validates :artist_id, :presence => true
  validates :album_id, :presence => true
  validates :title, :presence => true
  validates :track_number, :presence => true
  validates :uri, :presence => true,
                  :uniqueness => { :case_sensitive => false }
  validates :modify_date, :presence => true

  belongs_to :artist
  belongs_to :album

	# Returns the epoch value of the last modified track or zero if there are no tracks.
	def self.last_modified()
		track = self.first(:order => "modify_date DESC")
		track.nil? ? 0 : track.modify_date
  end
end
