class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string :name, :null => false
      t.string :uri, :null => false
      t.binary :cover, :null => true
      t.timestamps
    end

		create_table :albums_artists, :id => false do |t|
			t.integer :album_id, :null => false
			t.integer :artist_id, :null => false
		end

		add_index :albums, :name, :name => :idx_albums_name
		add_index :albums, :uri, :name => :idx_albums_uri
		add_index :albums_artists, [:album_id, :artist_id], :name => :idx_albums_artists_album_id_artist_id
		add_index :albums_artists, :album_id, :name => :idx_albums_artists_album_id
		add_index :albums_artists, :artist_id, :name => :idx_albums_artists_artist_id
  end

  def self.down
		remove_index :albums, :name => :idx_albums_name
		remove_index :albums, :name => :idx_albums_uri
		remove_index :albums_artists, :name => :idx_albums_artists_album_id_artist_id
		remove_index :albums_artists, :idx_albums_artists_album_id
		remove_index :albums_artists, :idx_albums_artists_artist_id
    drop_table :albums
  end
end
