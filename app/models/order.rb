class Order < ApplicationRecord
  belongs_to :user
  belongs_to :route
  monetize :amount_cents
end
