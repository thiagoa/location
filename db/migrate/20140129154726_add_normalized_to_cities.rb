class AddNormalizedToCities < ActiveRecord::Migration
  def change
    add_column :location_cities, :normalized, :boolean, default: true
  end
end
