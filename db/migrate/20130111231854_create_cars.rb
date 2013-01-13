class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :name
      t.string :engine_type
      t.string :exterior
      t.string :interior
      t.string :vin
      t.integer :fuel
      t.boolean :free

      t.timestamps
    end
    add_index(:cars, :vin,:unique => true)
  end
end
