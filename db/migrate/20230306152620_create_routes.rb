class CreateRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :routes do |t|
      t.string :destination
      t.integer :total_price
      t.date :start_date
      t.date :end_date
      t.integer :budget
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
