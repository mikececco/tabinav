class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :routes
  has_many :bookmarks, through: :routes
  has_many :bookings, through: :bookmarks
  has_many :orders
  # validates :first_name, presence: true
  # validates :last_name, presence: true
end
