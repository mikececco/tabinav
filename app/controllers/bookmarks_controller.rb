class BookmarksController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:create]

  def index
    # test UserMailer
    UserMailer.with(user: current_user).welcome.deliver_now

    @bookmarks = current_user.bookmarks.order(created_at: :desc).select { |bookmark| bookmark.booking.nil? }
    @booking = Booking.new
  end

  def create
    @bookmark = Bookmark.new
    @route = Route.find(params[:route_id])
    if @route.user == current_user
      @bookmark.route = @route
      if @bookmark.save
        redirect_to bookmarks_path
      end
    else
      new_route = @route.dup
      # add option to change dates
      new_route.user = current_user
      if new_route.save
        @route.days.each do |day|
          new_day = day.dup
          new_day.route = new_route
          new_day.save
        end
        @bookmark.route = new_route
        if @bookmark.save
          redirect_to bookmarks_path
        end
      end
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    redirect_back(fallback_location: root_path)#, status: :see_other
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:description)
  end
end
