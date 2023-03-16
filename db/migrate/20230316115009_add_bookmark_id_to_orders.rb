class AddBookmarkIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :bookmark, index: true, foreign_key: true
    remove_reference :orders, :route, index: true, foreign_key: true
  end
end
