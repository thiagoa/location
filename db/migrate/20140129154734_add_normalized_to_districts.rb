class AddNormalizedToDistricts < ActiveRecord::Migration
  def change
    add_column :location_districts, :normalized, :boolean, default: true
  end
end
