class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @route = Route.new
    good_routes = Route.where.not(total_price: 0).reject { |route| route.user == current_user }
    @routes = good_routes.nil? ? false : good_routes.sample(4)
  end
end
