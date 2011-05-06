class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table :artists do |t|
      t.string :name, :null => false
      t.timestamps
    end

		add_index :artists, :name, :name => :idx_artists_name
  end

  def self.down
		remove_index :artists, :name => :idx_artists_name
    drop_table :artists
  end
end
