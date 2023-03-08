class RoutesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

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
    @days = @route.days
  end

  def create
    @route = Route.new(route_params)
    @route.user = current_user
    if @route.save
      # maybe redirect to other pages first while waiting for api?
      destination = @route.destination == "" ? Route.all.sample : @route.destination
      no_of_days = (@route.end_date - @route.start_date + 1).to_i

      @response = ChatgptService.call("
        I want to go on a trip around #{destination}.
        I will be departing the #{@route.start_date} and leaving on the #{@route.end_date}.
        The itinerary will be #{no_of_days} days long. Distance with the previous day should be less than 100km.
        Give itinerary for each day.
        Suggest places to visit within €#{@route.budget}, convert all prices to euro.
        Include coordinates of the places recommended.
        Specify the city and country.
        Use only english language.
        Keep the description of the place within 200-300 characters.
        Be creative and inspire me.
        Respond with just the entire response in JSON.
        Example response for 2 stops:
        [{
          'day1': {
            'name': 'Van Gogh Museum',
            'price': 0,
            'city': 'Amsterdam',
            'country':'Netherlands',
            'description': 'The Van Gogh Museum is an art museum dedicated to the works of Vincent van Gogh and his contemporaries in Amsterdam in the Netherlands.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
        }, {
          'day2': {
            'name': 'Anne Frank House',
            'price': 20,
            'city': 'Netherlands',
            'country':'NL',
            'description': 'The Van Gogh Museum is an art museum dedicated to the works of Vincent van Gogh and his contemporaries in Amsterdam in the Netherlands.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
        }]
        Respond just with the JSON.
      ")
      @response = JSON.parse(@response)

      country_array = []

      @response.each_with_index do |hash, i|
        day = Day.new(route: @route)

        day.name = hash["day#{i + 1}"]["name"]
        day.description = hash["day#{i + 1}"]["description"]
        day.price = hash["day#{i + 1}"]["price"]
        day.latitude = hash["day#{i + 1}"]["coordinates"]["latitude"]
        day.longitude = hash["day#{i + 1}"]["coordinates"]["longitude"]
        day.city = hash["day#{i + 1}"]["city"]
        day.country = hash["day#{i + 1}"]["country"]
        day.save

        country_array << day.country unless country_array.include?(day.country)
        @route.total_price += day.price
      end

      # no_of_days.times do |i|
      #   name = "#{@response["day#{i + 1}"]["city"]} - #{@response.first["day#{i + 1}"]["name"]}"
      #   description = @response["day#{i + 1}"]["description"]
      #   price = @response["day#{i + 1}"]["price"]
      #   latitude = @response["day#{i + 1}"]["latitude"]
      #   longitude = @response["day#{i + 1}"]["longitude"]
      #   city = @response["day#{i + 1}"]["city"]
      #   Day.create(name: name, description: description, price: price, latitude: latitude, longitude: longitude, route: @route)

      #   city_array << city unless city_array.include?(city)
      #   @route.total_price += price
      # end

      @route.destination = country_array.join(" | ")
      if @route.save
        redirect_to route_path(@route)
      end
    end
    @route.destroy if @route.days == []
  end

  private

  def route_params
    params.require(:route).permit(:budget, :start_date, :end_date)
  end
end
