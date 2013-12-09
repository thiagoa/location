class CreateLocationAddresses < ActiveRecord::Migration
  def change
    create_table :location_addresses do |t|
      t.string :postal_code
      t.string :address
      t.string :number
      t.string :complement
      t.references :district, index: true
      t.references :city, index: true
      t.references :state, index: true
      t.decimal :latitude
      t.decimal :longitude
      t.references :addressable, polymorphic: true

      t.timestamps
    end

    add_index :location_addresses, [:addressable_type, :addressable_id], 
              name: 'index_location_addressable_id_and_type'
  end
end
