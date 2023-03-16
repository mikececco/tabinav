class AddPriceToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_monetize :routes, :price, currency: { present: false }
  end
end
