class BookingsController < ApplicationController
  def index
    @bookings = current_user.bookings
  end

  def create
    @bookmark = Bookmark.find(params[:bookmark_id])
    @booking = Booking.new(bookmark: @bookmark)
    if @booking.save
      mail = User.Mailer.with(user: current_user).welcome.deliver_now
      redirect_to bookings_path
    end
  end
end
