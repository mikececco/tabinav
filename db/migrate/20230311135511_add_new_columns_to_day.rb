class AddNewColumnsToDay < ActiveRecord::Migration[7.0]
  def change
    add_column :days, :room_type, :string
    add_column :days, :no_of_rooms, :integer
  end
end
