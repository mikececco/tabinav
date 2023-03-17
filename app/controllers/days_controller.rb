class DaysController < ApplicationController
  def index
  #   @route = Route.last
  #   @days = @route.days
  #   # The `geocoded` scope filters only flats with coordinates
  #   @markers = @days.map do |day|
  #     {
  #       lat: day.latitude,
  #       lng: day.longitude,
  #       info_window_html: render_to_string(partial: "info_window", locals: {day: day})
  #     }
  #   end

  #   @rmarkersfirst = @days.where(id: @days.minimum(:id)).map do |day|
  #     {
  #       lat: day.latitude,
  #       lng: day.longitude
  #     }
  #   end
  end

  def create
    @day = Day.new(day_params)
    @route = Route.find(params[:route_id])
    @day.route = @route

    if @day.save
      redirect_to days_path
    end
  end

  def update
    @day = Day.find(params[:id])
    old_price = @day.price_hotel
    @response = ChatgptService.call("
      I want to find another hotel in #{@day.city} with price about #{@day.price_hotel * 1.2}.
      Convert all prices to euro.
      Include coordinates of the places recommended.
      Use only english language.
      Keep the description of the place within 200-300 characters.
      Be creative and inspire me.
      Respond with just the entire response in JSON.
      Example response:
      [{
        'name': 'Crowne Plaza Amsterdam Zuid',
        'room_type': 'Twin Room',
        'no_of_people_per_room': 2,
        'price': 110,
        'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
        'coordinates': {
        'latitude': 56.358468,
        'longitude': 4.881119
        }
      }]
      Respond just with the JSON.
    ")
    hash = JSON.parse(@response).first

    route = @day.route
    @days = Day.where(route: route, name_hotel: @day.name_hotel)
    @days.each do |day|
      day.name_hotel = hash["name"]
      day.description_hotel = hash["description"]
      day.price_hotel = hash["price"]
      day.room_type = hash["room_type"]
      day.no_of_rooms = day.route.no_of_people.fdiv(hash["no_of_people_per_room"]).ceil
      day.latitude_hotel = hash["coordinates"]["latitude"]
      day.longitude_hotel = hash["coordinates"]["longitude"]
      if day.save
        route.total_price += (day.price_hotel - old_price) * day.no_of_rooms
      end
    end
    route.save
    redirect_to route_path(route), status: :see_other
  end

  def upgrade_hotel
    @day = Day.find(params[:day_id])
    old_price = @day.price_hotel
    @response = ChatgptService.call("
      I want to find another hotel in #{@day.city} with price about #{@day.price_hotel * 1.2}.
      Convert all prices to euro.
      Include coordinates of the places recommended.
      Use only english language.
      Keep the description of the place within 200-300 characters.
      Be creative and inspire me.
      Respond with just the entire response in JSON.
      Example response:
      [{
        'name': 'Crowne Plaza Amsterdam Zuid',
        'room_type': 'Twin Room',
        'no_of_people_per_room': 2,
        'price': 110,
        'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
        'coordinates': {
        'latitude': 56.358468,
        'longitude': 4.881119
        }
      }]
      Respond just with the JSON.
    ")
    hash = JSON.parse(@response).first

    route = @day.route
    @days = Day.where(route: route, name_hotel: @day.name_hotel)
    @days.each do |day|
      day.name_hotel = hash["name"]
      day.description_hotel = hash["description"]
      day.price_hotel = hash["price"]
      day.room_type = hash["room_type"]
      day.no_of_rooms = day.route.no_of_people.fdiv(hash["no_of_people_per_room"]).ceil
      day.latitude_hotel = hash["coordinates"]["latitude"]
      day.longitude_hotel = hash["coordinates"]["longitude"]
      if day.save
        route.total_price += (day.price_hotel - old_price) * day.no_of_rooms
      end
    end
    route.save
    respond_to do |format|
      format.html { redirect_to route_path(route), status: :see_other }
      format.text { render partial: "routes/hotel_info", locals: {day: @day}, formats: [:html] }
    end
  end

  def downgrade_hotel
    @day = Day.find(params[:day_id])
    old_price = @day.price_hotel
    if @day.city == "Queenstown"
      hash = {
        'name': 'The Rees Hotel & Luxury Apartments',
        'room_type': 'Deluxe Lakeview Hotel Room',
        'no_of_people_per_room': 2,
        'price': 257.9,
        'description': 'Experience luxury and stunning views of Lake Wakatipu at The Rees Hotel. Enjoy the exceptional service, fine dining, and spacious rooms and suites. Take a short walk to the Queenstown Gardens or hop on a shuttle to reach the town center easily.',
        'coordinates': {
        'latitude': -45.03228456452642,
        'longitude': 168.66300402905625
        }
      }
      route = @day.route
      @days = Day.where(route: route, name_hotel: @day.name_hotel)
      @days.each do |day|
        day.name_hotel = hash[:name]
        day.description_hotel = hash[:description]
        day.price_hotel = hash[:price]
        day.room_type = hash[:room_type]
        day.no_of_rooms = day.route.no_of_people.fdiv(hash[:no_of_people_per_room]).ceil
        day.latitude_hotel = hash[:coordinates][:latitude]
        day.longitude_hotel = hash[:coordinates][:longitude]
        if day.save
          route.total_price += (day.price_hotel - old_price) * day.no_of_rooms
        end
      end
    else
      @response = ChatgptService.call("
        I want to find another hotel in #{@day.city} with price about #{@day.price_hotel * 0.8}.
        Convert all prices to euro.
        Include coordinates of the places recommended.
        Use only english language.
        Keep the description of the place within 200-300 characters.
        Be creative and inspire me.
        Respond with just the entire response in JSON.
        Example response:
        [{
          'name': 'Crowne Plaza Amsterdam Zuid',
          'room_type': 'Twin Room',
          'no_of_people_per_room': 2,
          'price': 110,
          'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
          'coordinates': {
          'latitude': 56.358468,
          'longitude': 4.881119
          }
        }]
        Respond just with the JSON.
      ")
      hash = JSON.parse(@response).first
      route = @day.route
      @days = Day.where(route: route, name_hotel: @day.name_hotel)
      @days.each do |day|
        day.name_hotel = hash["name"]
        day.description_hotel = hash["description"]
        day.price_hotel = hash["price"]
        day.room_type = hash["room_type"]
        day.no_of_rooms = day.route.no_of_people.fdiv(hash["no_of_people_per_room"]).ceil
        day.latitude_hotel = hash["coordinates"]["latitude"]
        day.longitude_hotel = hash["coordinates"]["longitude"]
        if day.save
          route.total_price += (day.price_hotel - old_price) * day.no_of_rooms
        end
      end

    end
    route.save
    respond_to do |format|
      format.html { redirect_to route_path(route), status: :see_other }
      format.text { render partial: "routes/hotel_info", locals: {day: @day}, formats: [:html] }
    end
  end

  def change_activity
    @day = Day.find(params[:day_id])
    route = @day.route
    old_price = @day.price
    @days = Day.where(route: route, city: @day.city)
    current_activities = []
    @days.each { |day| current_activities << day.name }

    if @day.city == "Auckland"
      hash = {
        'name': 'Waiheke Island',
        'price': 40,
        'description': 'Take a ferry to Waiheke Island and enjoy the beautiful beaches and wineries. This island is known for its laid-back vibe and stunning scenery.',
        'coordinates': {
          'latitude': -36.791,
          'longitude': 175.0989
        }
      }

      @day.name = hash[:name]
      @day.description = hash[:description]
      @day.price = hash[:price]
      @day.latitude = hash[:coordinates][:latitude]
      @day.longitude = hash[:coordinates][:longitude]
      if @day.save
        route.total_price += (@day.price - old_price) * route.no_of_people
      end

      route.save
      redirect_to route_path(route), status: :see_other
    else
      @response = ChatgptService.call("
        I want to find another place to visit in #{@day.city} except #{current_activities.join(", ")}.
        Convert all prices to euro. Price can be 0.
        Include coordinates of the places recommended.
        Use only english language.
        Keep the description of the place within 200-300 characters.
        Be creative and inspire me.
        Respond with just the entire response in JSON.
        Example response:
        [{
          'name': 'Grand Place',
          'price': 20,
          'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
          'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
          }
        }]
        Respond just with the JSON.
      ")
      hash = JSON.parse(@response).first

      @day.name = hash["name"]
      @day.description = hash["description"]
      @day.price = hash["price"]
      @day.latitude = hash["coordinates"]["latitude"]
      @day.longitude = hash["coordinates"]["longitude"]
      if @day.save
        route.total_price += (@day.price - old_price) * route.no_of_people
      end

      route.save
      redirect_to route_path(route), status: :see_other
    end

  end

  def update_sequence
    days = JSON.parse(params["days_order"])
    route = Day.find(days.keys.first.to_i).route
    days.each do |day, sequence|
      new_day = Day.find(day.to_i)
      new_day.sequence = sequence
      new_day.save!
    end
    redirect_to route_path(route), status: :see_other

  end

  private

  def day_params
    params.require(:day).permit(:title, :description, :longitude, :latitute)
  end
end
