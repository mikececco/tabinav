class AddPackAdviceToBooking < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :pack_advice, :text
  end
end
