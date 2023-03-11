class AddColumnsToRoute < ActiveRecord::Migration[7.0]
  def change
    add_column :routes, :no_of_people, :integer
    add_column :routes, :hotel_pref, :string
  end
end
