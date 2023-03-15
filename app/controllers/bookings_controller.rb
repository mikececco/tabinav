class BookingsController < ApplicationController
  def index
    @bookings = current_user.bookings.order(created_at: :desc)

  end

  def show
    @booking = Booking.find(params[:id])
    @route = @booking.bookmark.route
  end

  def new
    @booking = Booking.new
  end

  def create
    @route = Route.find(params[:route_id])
    if @route.bookmark.nil?
      @bookmark = Bookmark.new
      @bookmark.route = @route if @route.user == current_user
      @bookmark.save
    else
      @bookmark = Bookmark.find(params[:bookmark_id])
    end
    @booking = Booking.new(bookmark: @bookmark)
    if @booking.save
      # mail = User.Mailer.with(user: current_user).welcome.deliver_now
      # pack_advice(@booking)
      redirect_to booking_path(@booking)
    else
      raise
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    redirect_back(fallback_location: root_path)#, status: :see_other
  end

  private

  def pack_advice(booking)
    route = @booking.bookmark.route
    @booking.pack_advice = ChatgptService.call("
      Suggest what to pack for a vacation in #{route.destination} in #{Date::MONTHNAMES[route.start_date.month]}.
      Respond in a list:
      - Lightweight and comfortable clothes: The weather in the Netherlands in May is usually mild, with average temperatures ranging from 10°C to 17°C. Pack clothes that can be layered to accommodate changes in temperature.\n\n
      - Rain jacket or umbrella: May is one of the rainiest months in the Netherlands, so it's a good idea to pack a waterproof jacket or umbrella.")
    @booking.save
  end
end
