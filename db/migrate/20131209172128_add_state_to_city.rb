class AddStateToCity < ActiveRecord::Migration
  def change
    add_reference :location_cities, :state, index: true
  end
end
