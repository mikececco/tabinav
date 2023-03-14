class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @route = Route.new
    @routes = Route.all.sample(4)
  end
end
