class DaysController < ApplicationController
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
