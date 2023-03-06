class CreateBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :bookmarks do |t|
      t.string :description
      t.references :route, null: false, foreign_key: true

      t.timestamps
    end
  end
end
