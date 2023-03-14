class Route < ApplicationRecord
  belongs_to :user
  has_one :bookmark, dependent: :destroy
  has_many :days, dependent: :destroy
  monetize :price_cents
end
