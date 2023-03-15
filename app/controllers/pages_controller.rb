class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @route = Route.new
    good_routes = Route.where.not(total_price: 0)
    @routes = good_routes.nil? ? Route.all.sample(4) : good_routes.sample(4)
  end
end
