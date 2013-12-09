class CreateLocationDistricts < ActiveRecord::Migration
  def change
    create_table :location_districts do |t|
      t.string :name

      t.timestamps
    end
  end
end
