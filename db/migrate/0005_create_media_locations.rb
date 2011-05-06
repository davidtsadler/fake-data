class CreateMediaLocations < ActiveRecord::Migration
  def self.up
    create_table :media_locations do |t|
		  t.string :directory
    end

		create_table :media_locations_media_types, :id => false do |t|
			t.integer :media_location_id
			t.integer :media_type_id
	  end
  end

  def self.down
    drop_table :media_locations
  end
end
