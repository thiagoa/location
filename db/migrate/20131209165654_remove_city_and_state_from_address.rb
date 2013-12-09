class RemoveCityAndStateFromAddress < ActiveRecord::Migration
  def change
    remove_column :location_addresses, :city_id
    remove_column :location_addresses, :state_id
  end
end
