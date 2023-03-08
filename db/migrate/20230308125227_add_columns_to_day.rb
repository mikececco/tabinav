class AddColumnsToDay < ActiveRecord::Migration[7.0]
  def change
    add_column :days, :price, :float
    add_column :days, :city, :string
    add_column :days, :country, :string
    change_column_default :routes, :total_price, 0
  end
end
