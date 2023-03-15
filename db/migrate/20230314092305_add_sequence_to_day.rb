class AddSequenceToDay < ActiveRecord::Migration[7.0]
  def change
    add_column :days, :sequence, :integer
  end
end
