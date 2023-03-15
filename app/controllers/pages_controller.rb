class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @route = Route.new
    @routes = Route.where.not(total_price: 0).sample(4)
  end
end
