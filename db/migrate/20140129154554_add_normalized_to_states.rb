class AddNormalizedToStates < ActiveRecord::Migration
  def change
    add_column :location_states, :normalized, :boolean, default: true
  end
end
