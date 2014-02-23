class RenameAddressToStreet < ActiveRecord::Migration
  def change
    rename_column :location_addresses, :address, :street
  end
end
