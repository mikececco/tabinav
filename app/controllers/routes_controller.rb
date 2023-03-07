class RoutesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @routes = current_user.routes
  end

  def show
    @route = Route.find(params[:id])
    @bookmark = Bookmark.new
  end

  def new
    @route = Route.new

  end
end
