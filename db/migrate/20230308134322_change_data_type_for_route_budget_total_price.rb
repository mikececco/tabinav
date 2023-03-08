class ChangeDataTypeForRouteBudgetTotalPrice < ActiveRecord::Migration[7.0]
  def change
    change_table :routes do |t|
      t.change :total_price, :float
      t.change :budget, :float
    end
  end
end
