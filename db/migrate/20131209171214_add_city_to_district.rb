class AddCityToDistrict < ActiveRecord::Migration
  def change
    add_reference :location_districts, :city, index: true
  end
end
