class BookmarksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]

  def index
    @bookmarks = current_user.bookmarks
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @route = Route.find(params[:route_id])
    @bookmark.route = @route
    @bookmark.save
    redirect_to route_path(@route)
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:description)
  end
end
