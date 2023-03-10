class Route < ApplicationRecord
  belongs_to :user
  has_one :bookmark, dependent: :destroy
  has_many :days, dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true
end
