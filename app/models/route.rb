class Route < ApplicationRecord
  belongs_to :user
  has_one :bookmark, dependent: :destroy
end
