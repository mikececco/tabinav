class Booking < ApplicationRecord
  belongs_to :bookmark

  validates :bookmark, presence: true, uniqueness: true
end
