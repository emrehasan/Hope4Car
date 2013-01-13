class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
    	t.integer :car_id
      t.string :address
      t.string :city
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    # add_index(:locations, [:latitude, :longitude], :unique => true)
  end
end
