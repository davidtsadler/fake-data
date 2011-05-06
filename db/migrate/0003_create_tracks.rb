class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
 			t.integer :artist_id, :null => false
      t.integer :album_id, :null => false
      t.string :title, :null => false
      t.integer :track_number, :null => false
      t.integer :year, :null => true
      t.string :genre, :null => true
	    t.string :uri, :null => false
			t.integer	:modify_date, :null => false
      t.timestamps
    end

		add_index :tracks, :artist_id, :name => :idx_tracks_artist_id
		add_index :tracks, :album_id, :name => :idx_tracks_album_id
		add_index :tracks, :title, :name => :idx_tracks_title
		add_index :tracks, :uri, :name => :idx_tracks_uri
  end

  def self.down
		remove_index :tracks, :name => :idx_tracks_artist_id
		remove_index :tracks, :name => :idx_tracks_album_id
		remove_index :tracks, :name => :idx_tracks_title
		remove_index :tracks, :name => :idx_tracks_uri
    drop_table :tracks
  end
end
