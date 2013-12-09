class CreateLocationStates < ActiveRecord::Migration
  def change
    create_table :location_states do |t|
      t.string :name
      t.string :abbr

      t.timestamps
    end
  end
end
