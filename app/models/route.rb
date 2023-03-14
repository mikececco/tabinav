class Route < ApplicationRecord
  monetize :price_cents
  belongs_to :user
  has_one :bookmark, dependent: :destroy
  has_many :days, dependent: :destroy
end
