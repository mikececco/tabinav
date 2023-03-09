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
    else
      raise
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    redirect_back(fallback_location: root_path)#, status: :see_other
  end
end
