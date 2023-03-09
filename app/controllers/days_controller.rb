class DaysController < ApplicationController
  def index
    @route = Route.last
    @days = @route.days
    # The `geocoded` scope filters only flats with coordinates
    @markers = @days.map do |day|
      {
        lat: day.latitude,
        lng: day.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {day: day})
      }
    end

    @rmarkersfirst = @days.where(id: @days.minimum(:id)).map do |day|
      {
        lat: day.latitude,
        lng: day.longitude
      }
    end
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
      I want to find another hotel in #{@day.city} with price about #{@day.price_hotel * 1.5}.
      Convert all prices to euro.
      Include coordinates of the places recommended.
      Use only english language.
      Keep the description of the place within 200-300 characters.
      Be creative and inspire me.
      Respond with just the entire response in JSON.
      Example response:
      [{
        'hotel': {
          'name': 'Crowne Plaza Amsterdam Zuid',
          'price': 110,
          'description': '5 star hotel with a sky bar and an indoor swimming pool.',
          'coordinates': {
          'latitude': 56.358468,
          'longitude': 4.881119
          }
        }
      }]
      Respond just with the JSON.
    ")
    hash = JSON.parse(@response).first

    @day.name_hotel = hash["hotel"]["name"]
    @day.description_hotel = hash["hotel"]["description"]
    @day.price_hotel = hash["hotel"]["price"]
    @day.latitude_hotel = hash["hotel"]["coordinates"]["latitude"]
    @day.longitude_hotel = hash["hotel"]["coordinates"]["longitude"]
    if @day.save
      route = @day.route
      redirect_to route_path(route), status: :see_other
      route.total_price += (@day.price_hotel - old_price)
      route.save
    end

  end

  private

  def day_params
    params.require(:day).permit(:title, :description, :longitude, :latitute)
  end
end
