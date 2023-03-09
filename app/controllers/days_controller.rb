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

  private

  def day_params
    params.require(:day).permit(:title, :description, :longitude, :latitute)
  end
end
