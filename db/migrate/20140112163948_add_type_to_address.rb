class AddTypeToAddress < ActiveRecord::Migration
  def change
    add_column :location_addresses, :type, :string
  end
end
