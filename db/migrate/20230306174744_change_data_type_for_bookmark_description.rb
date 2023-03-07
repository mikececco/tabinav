class ChangeDataTypeForBookmarkDescription < ActiveRecord::Migration[7.0]
  def change
    change_table :bookmarks do |t|
      t.change :description, :text
    end
  end
end
