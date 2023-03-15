class AddColumnsToDays < ActiveRecord::Migration[7.0]
  def change
    add_column :days, :name_hotel, :string
    add_column :days, :description_hotel, :text
    add_column :days, :latitude_hotel, :float
    add_column :days, :longitude_hotel, :float
    add_column :days, :price_hotel, :float
    rename_column :days, :country, :nation
  end
end
