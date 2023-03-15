class RoutesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    if user_signed_in?
      @routes = current_user.routes
    else
      @routes = Route.all
    end
  end

  def show
    @route = Route.find(params[:id])
    @bookmark = Bookmark.new
    @days = @route.days.order(sequence: :asc)

    @countries = []
    @route.days.each do |day|
      @countries << day.nation unless @countries.include?(day.nation)
    end

    @markers = @days.map do |day|
      {
        lat: day.latitude,
        lng: day.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { day: day }),
        # logo_marker_html: render_to_string(partial: "logo_marker", locals: {day: day})
      }
    end

    # @rmarkersfirst = @days.where(id: @days.minimum(:id)).map do |day|
    #   {
    #     lat: day.latitude,
    #     lng: day.longitude,
    #     info_window_html: render_to_string(partial: "first_marker", locals: {day: day}),
    #     logo_first_marker_html: render_to_string(partial: "logo_first_marker", locals: {day: day})
    #   }
    # end
  end

  def create
    @route = Route.new(route_params)
    @route.user = current_user
    if @route.save
      pick_cities(@route)
    end
    Route.all.each do |route|
      route.destroy if @route.destination == nil
    end
  end

  private

  def route_params
    params.require(:route).permit(:budget, :start_date, :end_date, :destination, :no_of_people, :hotel_pref)
  end

  def pick_cities(route)
    destination = route.destination == "" ? Route.all.sample.days.sample.city : route.destination
    route.no_of_people = 2 if route.no_of_people == nil

    no_of_days = (route.end_date - route.start_date + 1).to_i
    no_of_cities = case no_of_days
      when 1..4 then 1
      when 5..7 then 2
      when 8..10 then 3
      else (no_of_days / 3).floor
    end

    @cities = ChatgptService.call("
      I want to go on a vacation in #{destination}.
      Suggest #{no_of_cities} cities around to visit.
      Specify the country.
      Respond with just the entire response in JSON with a total of #{no_of_days} days.
      Example response for 3 cities with a total of 8 days:
      [
        { 'city'=>'Amsterdam', 'country'=> 'Netherlands', 'days'=> 3 },
        { 'city'=>'Rotterdam', 'country'=> 'Netherlands', 'days'=> 3 },
        { 'city'=>'Brussels', 'country'=> 'Belgium', 'days'=> 2 }
      ]
      Respond just with the JSON.")

      @cities = JSON.parse(@cities)
      hotel_average_price = check_hotel_price(@cities.first["city"])
      generate_days(@cities, @route, hotel_average_price, no_of_days)

  end

  def check_hotel_price(city)
    hotel_average_price = ChatgptService.call("
      Name any 3-star hotel in #{city}.
      Convert price to Euro.
      Respond with just the entire response in JSON.
      Example response for Amsterdam:
      [{
        'name': 'Crowne Plaza Amsterdam Zuid',
        'price': 110,
        'coordinates': {
        'latitude': 56.358468,
        'longitude': 4.881119
        }
      }]
      Respond just with the JSON.
      ")

      hotel_average_price.include?("AI") ? 80 : JSON.parse(hotel_average_price).first["price"]
  end

  def generate_days(cities_hash, route, hotel_average_price, no_of_days)
      no_of_rooms = route.no_of_people.fdiv(2).ceil
      daily_hotel_budget = (route.budget - (15 * route.no_of_people * no_of_days)) / no_of_days / no_of_rooms

      hotel_description = case daily_hotel_budget / hotel_average_price * 100
        when 0...50 then "Choose a hostel to stay."
        when 50...100 then "Choose a 2-star hotel."
        when 100...150 then "Choose a 3-star hotel."
        when 150...300 then "Choose a 4-star hotel."
        else "Choose a 5-star hotel."
        # else "Choose a hotel with price from €#{hotel_price * 0.9} to €#{hotel_price}."
      end

      country_array = []

      cities_hash.each do |hash|
        result = ChatgptService.call("
          Suggest #{hash["days"]} places to visit in #{hash["city"]}
          #{hotel_description}, convert all prices to euro.
          Include coordinates of the places recommended.
          Use only english language.
          Keep the description of the place within 250-300 characters.
          Be creative and inspire me.
          Respond with just the entire response in JSON.
          Example response:
          [{
            'city': '#{hash["city"]}',
            'country':'#{hash["country"]}',
            'hotel': {
              'name': 'Crowne Plaza Amsterdam Zuid',
              'room_type': 'Twin Room',
              'no_of_people_per_room': 2,
              'price': 110,
              'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
              'coordinates': {
                'latitude': 56.358468,
                'longitude': 4.881119
              }
            },
            'activity1': {
              'name': 'Grand Place',
              'price': 0,
              'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
              'coordinates': {
                'latitude': 52.358468,
                'longitude': 4.881119
              }
            },
            ...,
            'activity#{hash["days"]}': {
              'name': 'Grand Place',
              'price': 0,
              'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
              'coordinates': {
                'latitude': 52.358468,
                'longitude': 4.881119
              }
            }
          }]
          Respond just with the JSON.")

        result = JSON.parse(result).first
        days = 1

        hash["days"].times do |i|
          day = Day.new(route: route, city: hash["city"])
          day.nation = result["country"]
          day.name_hotel = result["hotel"]["name"]
          day.description_hotel = result["hotel"]["description"]
          day.price_hotel = result["hotel"]["price"]
          day.room_type = result["hotel"]["room_type"]
          day.no_of_rooms = route.no_of_people.fdiv(result["hotel"]["no_of_people_per_room"]).ceil
          day.latitude_hotel = result["hotel"]["coordinates"]["latitude"]
          day.longitude_hotel = result["hotel"]["coordinates"]["longitude"]

          day.name = result["activity#{i + 1}"]["name"]
          day.description = result["activity#{i + 1}"]["description"]
          day.price = result["activity#{i + 1}"]["price"]
          day.latitude = result["activity#{i + 1}"]["coordinates"]["latitude"]
          day.longitude = result["activity#{i + 1}"]["coordinates"]["longitude"]
          day.sequence = days
          days += 1

          day.save

          country_array << day.nation.capitalize unless country_array.include?(day.nation.capitalize)
          route.total_price += ( day.price * route.no_of_people + day.price_hotel * day.no_of_rooms)
        end
      end
    assign_destination_to_route(route, country_array)
  end

  def assign_destination_to_route(route, country_array)
    route.destination = country_array.join(", ")
    if route.save
      redirect_to route_path(route)
    end
  end
end
