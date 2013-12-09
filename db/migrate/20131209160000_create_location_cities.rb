class CreateLocationCities < ActiveRecord::Migration
  def change
    create_table :location_cities do |t|
      t.string :name

      t.timestamps
    end
  end
end
