class Bookmark < ApplicationRecord
  belongs_to :route
  # belongs_to :user, through: :route
end
