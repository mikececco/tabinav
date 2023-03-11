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
    @days = @route.days.order(created_at: :asc)

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
      generate_days(@route)
    end
    Route.all.each do |route|
      route.destroy if @route.destination == nil
    end
  end

  private

  def route_params
    params.require(:route).permit(:budget, :start_date, :end_date, :destination, :no_of_people, :hotel_pref)
  end

  def generate_days(route)
    destination = route.destination == "" ? Route.all.sample : route.destination
    route.no_of_people = 2 if route.no_of_people == nil
    rooms = route.no_of_people.fdiv(2).ceil
    route.hotel_pref = case route.budget / rooms / route.no_of_people
      when 0...100 then "cheapest accommodation"
      when 100...150 then "3-Star Hotel"
      when 150...200 then "4-Star Hotel"
      else "Luxury Hotel"
    end

    route.hotel_pref = ["luxury hotel", "3-star hotel", "cheapest accommodation"].sample
    no_of_days = (route.end_date - route.start_date + 1).to_i
    country_array = []
    hotel_price = route.budget / no_of_days / rooms - 20 * route.no_of_people
    # with price less than €#{route.budget / no_of_days - 20 * no_of_people}.
    # Choose #{@route.hotel_pref}.

    @response = ChatgptService.call("
      I want to go on a trip around #{destination}.
      I will be departing the #{route.start_date} and leaving on the #{route.end_date}.
      The itinerary will be #{no_of_days} days long.
      Give itinerary for each day. Take travelling time into account.
      Suggest places to visit, convert all prices to euro.
      Choose a hotel with price from €#{hotel_price * 0.9} to €#{hotel_price} per night.
      Same hotel in the same city.
      Include coordinates of the places recommended.
      Specify the city and country.
      Use only english language.
      Keep the description of the place within 250-300 characters.
      Be creative and inspire me.
      Respond with just the entire response in JSON.
      Example response for 2 stops:
      [
        {'day1': {
          'city': 'Amsterdam',
          'country':'Netherlands',
          'activity': {
            'name': 'Van Gogh Museum',
            'price': 20,
            'description': 'The Van Gogh Museum is an art museum dedicated to the works of Vincent van Gogh and his contemporaries in Amsterdam in the Netherlands.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
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
          }
        }}, {
        'day2': {
          'city': 'Amsterdam',
          'country': 'Netherlands',
          'activity': {
            'name': 'Jordaan',
            'price': 0,
            'description': 'Jordaan is a district in the citycenter of Amsterdam, known for its beautiful houses, nice restaurants and original shops. On the many bridges over the canals, you can take beautiful pictures and see why Amsterdam is called the Venice of the North.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
          'hotel': {
            'name': 'Crowne Plaza Amsterdam Zuid',
            'room_type': 'Twin Room',
            'no_of_people_per_room': 2,
            'price': 110,
            'description': '5 star hotel with a sky bar and an indoor swimming pool.',
            'coordinates': {
            'latitude': 56.358468,
            'longitude': 4.881119
            }
          }
        }}]
      Respond just with the JSON.
    ")
    @response = JSON.parse(@response)

    @response.each_with_index do |hash, i|
      day = Day.new(route: route)

      day.name = hash["day#{i + 1}"]["activity"]["name"]
      day.description = hash["day#{i + 1}"]["activity"]["description"]
      day.price = hash["day#{i + 1}"]["activity"]["price"]
      day.latitude = hash["day#{i + 1}"]["activity"]["coordinates"]["latitude"]
      day.longitude = hash["day#{i + 1}"]["activity"]["coordinates"]["longitude"]
      day.city = hash["day#{i + 1}"]["city"]
      day.nation = hash["day#{i + 1}"]["country"]
      day.name_hotel = hash["day#{i + 1}"]["hotel"]["name"]
      day.description_hotel = hash["day#{i + 1}"]["hotel"]["description"]
      day.price_hotel = hash["day#{i + 1}"]["hotel"]["price"]
      day.room_type = hash["day#{i + 1}"]["hotel"]["room_type"]
      day.no_of_rooms = route.no_of_people.fdiv(hash["day#{i + 1}"]["hotel"]["no_of_people_per_room"]).ceil
      day.latitude_hotel = hash["day#{i + 1}"]["hotel"]["coordinates"]["latitude"]
      day.longitude_hotel = hash["day#{i + 1}"]["hotel"]["coordinates"]["longitude"]
      day.save

      country_array << day.nation unless country_array.include?(day.nation)
      @route.total_price += ( day.price * route.no_of_people + day.price_hotel * day.no_of_rooms)
    end
    assign_destination_to_route(route, country_array)
  end

  def assign_destination_to_route(route, country_array)
    route.destination = country_array.join(" | ")
    if route.save
      redirect_to route_path(route)
    end
  end
end
