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
    @bookmark = Bookmark.find(params[:bookmark_id])
    @route = @bookmark.route
    # if @route.bookmark.nil?
    #   @bookmark = Bookmark.new
    #   @bookmark.route = @route if @route.user == current_user
    #   @bookmark.save
    # else
    # end
    @booking = Booking.new#(bookmark: @bookmark)
    @booking.bookmark = @bookmark
    if @bookmark.route.destination.downcase == "new zealand"
      @bookmark.route.destination.downcase == "new zealand"
      pack_advice_nz_april(@booking)
    end
    if @booking.save
      # mail = User.Mailer.with(user: current_user).welcome.deliver_now
      #
      redirect_to booking_path(@booking)
    else
      raise
    end
  end

  def hack
    @bookmark = Bookmark.find(params[:bookmark_id])
    @route = @bookmark.route
    # if @route.bookmark.nil?
    #   @bookmark = Bookmark.new
    #   @bookmark.route = @route if @route.user == current_user
    #   @bookmark.save
    # else
    # end
    @booking = Booking.new#(bookmark: @bookmark)
    @booking.bookmark = @bookmark
    if @bookmark.route.destination.downcase == "new zealand"
      pack_advice_nz_april(@booking)
    end

    if @booking.save
      # mail = User.Mailer.with(user: current_user).welcome.deliver_now
      #
      redirect_to booking_path(@booking)
    else
      raise
    end
  end

  def update
    @booking = Booking.find(params[:id])
    pack_advice(@booking)
    redirect_to booking_path(@booking)
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    redirect_to bookings_path, status: :see_other
  end

  def show
    @booking = Booking.find(params[:id])
    @route = @booking.bookmark.route
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

  private

  def pack_advice(booking)
    route = @booking.bookmark.route
    @booking.pack_advice = ChatgptService.call("
      Suggest what to pack for a vacation in #{route.destination} in #{Date::MONTHNAMES[route.start_date.month]}.
      Respond in an ordered list")
    @booking.save
  end

  def pack_advice_nz_april(booking)
    booking.pack_advice = "New Zealand can experience a wide range of weather conditions in April, so it's important to pack for both warm and cool weather. Here are some suggestions on what to pack for a vacation in New Zealand in April:\n\n
                          1. Comfortable walking shoes: New Zealand is a great place to explore on foot, so bring comfortable walking shoes for hiking and exploring.\n
                          2. Light layers: April is a transitional month, and temperatures can vary from chilly mornings to warm afternoons. Bring light layers such as a sweater, jacket, and t-shirts to adjust to the changing weather.\n
                          3. Waterproof jacket: New Zealand can experience sudden rain showers, so it's a good idea to pack a waterproof jacket or raincoat.\n
                          4. Swimwear: If you're planning to visit any of the beautiful beaches in New Zealand, make sure to pack swimwear.\n
                          5. Sunscreen and sunglasses: The sun can be strong in New Zealand, even in April, so don't forget to pack sunscreen and sunglasses to protect your skin and eyes.\n
                          6. Camera: New Zealand is known for its stunning landscapes and natural beauty, so make sure to bring a camera to capture all the amazing views.\n
                          7. Power adapter: New Zealand uses a different type of power outlet than many other countries, so don't forget to pack a power adapter if you plan to use any electronic devices.\n
                          8. Medications: If you take any prescription medications, make sure to bring enough for the duration of your trip, as well as any over-the-counter medicines you might need.\n
                          9. Travel documents: Don't forget to bring your passport, visa (if required), and any other travel documents you might need.\n
                          10. Cash and credit card: Make sure to bring some New Zealand dollars in cash and a credit card for any purchases you might make during your trip."
  end
end
