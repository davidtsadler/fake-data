class CreateMediaTypes < ActiveRecord::Migration
  def self.up
    create_table :media_types do |t|
			t.string :name
    end

		["Video","Music","Photo"].each { |m| MediaType.create(:name => "#{m}") }
  end

  def self.down
    drop_table :media_types
  end
end
