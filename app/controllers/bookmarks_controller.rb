class BookmarksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]

  def index
    # test UserMailer
    UserMailer.with(user: current_user).welcome.deliver_now

    @bookmarks = current_user.bookmarks
    @booking = Booking.new
  end

  def create
    @bookmark = Bookmark.new
    @route = Route.find(params[:route_id])
    @bookmark.route = @route
    if @bookmark.save
      redirect_to bookmarks_path
    end
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:description)
  end
end
