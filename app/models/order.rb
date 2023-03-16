class Order < ApplicationRecord
  belongs_to :user
  monetize :amount_cents
  has_one :bookmark
end
