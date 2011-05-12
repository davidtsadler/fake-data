class AddAlbumsCoverUrlField < ActiveRecord::Migration
  def self.up
    change_table :albums do |t|
      t.string :cover_url, :null => true
    end
  end

  def self.down
    change_table :albums do |t|
      t.remove :permalink
    end
  end
end
