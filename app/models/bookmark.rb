class Bookmark < ApplicationRecord
  belongs_to :route
  has_one :user, through: :route

  validates :route, presence: true, uniqueness: true#, message: "You have already bookmarked this route!" }
end
