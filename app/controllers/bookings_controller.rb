class BookingsController < ApplicationController
  def index
    @bookings = current_user.bookings
  end

  def new
    @booking = Booking.new
  end

  def create
    @bookmark = Bookmark.find(params[:bookmark_id])
    @booking = Booking.new(bookmark: @bookmark)
    if @booking.save
      redirect_to bookings_path
    end
  end
end
