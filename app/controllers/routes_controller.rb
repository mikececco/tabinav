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

    @response = ChatgptService.call("
      I want to go on a trip from Amsterdam to a destination in a foreign country chosen by you.
      I will be departing the 2021-07-01 and leaving on the 2021-07-05.
      The itinerary will be 4 days long.
      Give itinerary for each day.
      Suggest places to visit.
      Include coordinates of the places recommended.
      Specify the city and country code.
      Respond with just the entire response in JSON.
      Use only english language.
      Keep the description of the place short.
      Be creative and inspire me.
      Example response for 2 stops:
      [{
          'day1': {
            'name': 'Van Gogh Museum',
          'city': 'Amsterdam',
          'country':'NL',
          'description': 'The Van Gogh Museum is an art museum dedicated to the works of Vincent van Gogh and his contemporaries in Amsterdam in the Netherlands.',
          'coordinates': {
          'latitude': 52.358468,
          'longitude': 4.881119
          }
        },
        'day2': {
          'name': 'Anne Frank House',
          'city': 'Amsterdam',
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
    @name = @response.first["day1"]["name"]
    @description = @response.first["day1"]["description"]

  end

  def new
    @route = Route.new

  end
end
