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
    # if @booking.save
    #   mail = User.Mailer.with(user: current_user).welcome.deliver_now
      redirect_to booking_path(@booking)
    # else
    #   raise
    # end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    redirect_back(fallback_location: root_path)#, status: :see_other
  end

  def show
    @booking = Booking.find(params[:id])
    @route = @booking.bookmark.route
  end
end
