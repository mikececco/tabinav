class RoutesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @route = Route.last
    if user_signed_in?
      @routes = current_user.routes
    else
      @routes = Route.all
    end
  end

  def show
    raise
    @route = Route.find(params[:id])
    @bookmark = Bookmark.new
    @booking = Booking.new
    @days = @route.days.order(sequence: :asc)

    @countries = []
    @route.days.each do |day|
      @countries << day.nation unless @countries.include?(day.nation)
    end

    @markers = @days.map do |day|
      {
        lat: day.latitude,
        lng: day.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { day: day }),
        # logo_marker_html: render_to_string(partial: "logo_marker", locals: {day: day})
      }
    end

    # @rmarkersfirst = @days.where(id: @days.minimum(:id)).map do |day|
    #   {
    #     lat: day.latitude,
    #     lng: day.longitude,
    #     info_window_html: render_to_string(partial: "first_marker", locals: {day: day}),
    #     logo_first_marker_html: render_to_string(partial: "logo_first_marker", locals: {day: day})
    #   }
    # end
  end

  def create
    @route = Route.new(route_params)
    @route.user = current_user
    if @route.save
      case @route.destination.downcase
      when "new zealand"
        # city_hash = [
        #   { 'city'=>'Auckland', 'country'=> 'New Zealand', 'days'=> 3 }
        # ]
        nz_hardcode_1(@route)
        nz_hardcode_2(@route)
        @route.destination = "New Zealand"
        if @route.save
          redirect_to route_path(@route)
        end
      else
        pick_cities(@route)
      end
    end
    Route.all.each do |route|
      route.destroy if route.total_price == 0
    end
  end

  private

  def route_params
    params.require(:route).permit(:budget, :start_date, :end_date, :destination, :no_of_people, :hotel_pref)
  end

  def pick_cities(route)
    destination = route.destination == "" ? Route.all.sample.days.sample.city : route.destination
    route.no_of_people = 2 if route.no_of_people == nil

    rooms = route.no_of_people.fdiv(2).ceil
    no_of_days = (route.end_date - route.start_date + 1).to_i
    no_of_cities = case no_of_days
                   when 1..4 then 1
                   when 5..7 then 2
                   when 8..10 then 3
                   else (no_of_days / 3).floor
                   end

    @cities = ChatgptService.call("
      I want to go on a vacation in #{destination}.
      Suggest #{no_of_cities} cities around to visit.
      Specify the country.
      Respond with just the entire response in JSON with a total of #{no_of_days} days.
      Example response for 3 cities with a total of 8 days:
      [
        { 'city'=>'Amsterdam', 'country'=> 'Netherlands', 'days'=> 3 },
        { 'city'=>'Rotterdam', 'country'=> 'Netherlands', 'days'=> 3 },
        { 'city'=>'Brussels', 'country'=> 'Belgium', 'days'=> 2 }
      ]
      Respond just with the JSON.")

      @cities = JSON.parse(@cities)
      # hotel_average_price = check_hotel_price(@cities.first["city"])
      hotel_average_price = 90

      generate_days(@cities, route, hotel_average_price, no_of_days)

  end

  def check_hotel_price(city)
    hotel_average_price = ChatgptService.call("
      Name any 3-star:hotelin #{city}.
      Convert price to Euro.
      Respond with just the entire response in JSON.
      Example response for Amsterdam:
      [{
        'name': 'Crowne Plaza Amsterdam Zuid',
        'price': 110,
        'coordinates': {
        'latitude': 56.358468,
        'longitude': 4.881119
        }
      }]
      Respond just with the JSON.
      ")

    hotel_average_price.include?("AI") ? 100 : JSON.parse(hotel_average_price).first["price"]
  end

  def generate_days(cities_hash, route, hotel_average_price, no_of_days)
    no_of_rooms = route.no_of_people.fdiv(2).ceil
    daily_hotel_budget = (route.budget - (25 * route.no_of_people * no_of_days)) / no_of_days / no_of_rooms

    hotel_description = case daily_hotel_budget / hotel_average_price * 100
                        when 0...50 then "Choose a hostel to stay."
                        when 50...100 then "Choose a 2-star hotel."
                        when 100...150 then "Choose a 3-star hotel."
                        when 150...300 then "Choose a 4-star hotel."
                        else "Choose a 5-star hotel."
                          # else "Choose a hotel with price from €#{hotel_price * 0.9} to €#{hotel_price}."
                        end

      country_array = []
      days = 1

      cities_hash.each do |hash|
        result = ChatgptService.call("
          Suggest #{hash["days"]} places to visit in #{hash["city"]}
          #{hotel_description}, convert all prices to euro.
          Include coordinates of the places recommended.
          Use only english language.
          Keep the description of the place within 250-300 characters.
          Be creative and inspire me.
          Respond with just the entire response in JSON.
          Example response:
          [{
            'city': '#{hash["city"]}',
            'country':'#{hash["country"]}',
            'hotel': {
              'name': 'Crowne Plaza Amsterdam Zuid',
              'room_type': 'Twin Room',
              'no_of_people_per_room': 2,
              'price': 110,
              'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
              'coordinates': {
                'latitude': 56.358468,
                'longitude': 4.881119
              }
            },
            'activity1': {
              'name': 'Grand Place',
              'price': 0,
              'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
              'coordinates': {
                'latitude': 52.358468,
                'longitude': 4.881119
              }
            },
            ...,
            'activity#{hash["days"]}': {
              'name': 'Grand Place',
              'price': 0,
              'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
              'coordinates': {
                'latitude': 52.358468,
                'longitude': 4.881119
              }
            }
          }]
          Respond just with the JSON.")

        result = JSON.parse(result).first

        hash["days"].times do |i|
          day = Day.new(route: route, city: hash["city"])
          day.nation = result["country"]
          day.name_hotel = result["hotel"]["name"]
          day.description_hotel = result["hotel"]["description"]
          day.price_hotel = result["hotel"]["price"]
          day.room_type = result["hotel"]["room_type"]
          day.no_of_rooms = route.no_of_people.fdiv(result["hotel"]["no_of_people_per_room"]).ceil
          day.latitude_hotel = result["hotel"]["coordinates"]["latitude"]
          day.longitude_hotel = result["hotel"]["coordinates"]["longitude"]

          day.name = result["activity#{i + 1}"]["name"]
          day.description = result["activity#{i + 1}"]["description"]
          day.price = result["activity#{i + 1}"]["price"]
          day.latitude = result["activity#{i + 1}"]["coordinates"]["latitude"]
          day.longitude = result["activity#{i + 1}"]["coordinates"]["longitude"]
          day.sequence = days
          days += 1

          day.save

          country_array << day.nation.capitalize unless country_array.include?(day.nation.capitalize)
          route.total_price += ( day.price * route.no_of_people + day.price_hotel * day.no_of_rooms)
        end
      end
    assign_destination_to_route(route, country_array)
  end

  def nz_hardcode_1(route)
    result = {
      'city': 'Auckland',
      'country': 'New Zealand',
      'hotel': {
        'name': 'The Grand by SkyCity',
        'room_type': 'Deluxe Queen Room',
        'no_of_people_per_room': 2,
        'price': 195.42,
        'description': 'Located in the heart of Auckland, The Grand by SkyCity offers impeccable service and luxurious amenities such as a 25-metre heated lap pool, fitness centre and sauna. This 5-star hotel is within walking distance of the city\'s top attractions.',
        'coordinates': {
          'latitude': -36.8485,
          'longitude': 174.7708
        }
      },
      'activity1': {
        'name': 'Auckland Domain',
        'price': 0,
        'description': 'One of Auckland\'s oldest and largest parks, the Auckland Domain features beautiful gardens, walking trails, historic monuments and the Auckland War Memorial Museum. It\'s the perfect place to relax and take in the natural beauty of the city.',
        'coordinates': {
          'latitude': -36.8642,
          'longitude': 174.7708
        }
      },
      'activity2': {
        'name': 'Auckland Harbour Bridge',
        'price': 141.65,
        'description': 'Climb to the top of Auckland Harbour Bridge, 67 metres above the sparkling Waitemata Harbour. This unforgettable experience also includes a commentary on the bridge\'s history and engineering, as well as stunning panoramic views.',
        'coordinates': {
          'latitude': -36.8203,
          'longitude': 174.7617
        }
      },
      'activity3': {
        'name': 'Sky Tower',
        'price': 32.25,
        'description': 'The tallest freestanding structure in the Southern Hemisphere, the Sky Tower offers breathtaking 360-degree views of Auckland from 220 metres above ground. It also features a revolving restaurant, SkyWalk and SkyJump activities.',
        'coordinates': {
          'latitude': -36.8485,
          'longitude': 174.7628
        }
      }
    }

    days = 1

    3.times do |i|
      day = Day.new(route: route, city: "Auckland")
      day.nation = result[:country]
      day.name_hotel = result[:hotel][:name]
      day.description_hotel = result[:hotel][:description]
      day.price_hotel = result[:hotel][:price]
      day.room_type = result[:hotel][:room_type]
      day.no_of_rooms = route.no_of_people.fdiv(result[:hotel][:no_of_people_per_room]).ceil
      day.latitude_hotel = result[:hotel][:coordinates][:latitude]
      day.longitude_hotel = result[:hotel][:coordinates][:longitude]

      day.name = result[:"activity#{i + 1}"][:name]
      day.description = result[:"activity#{i + 1}"][:description]
      day.price = result[:"activity#{i + 1}"][:price]
      day.latitude = result[:"activity#{i + 1}"][:coordinates][:latitude]
      day.longitude = result[:"activity#{i + 1}"][:coordinates][:longitude]
      day.sequence = days
      days += 1

      day.save

      route.total_price += ( day.price * route.no_of_people + day.price_hotel * day.no_of_rooms)
    end
  end

  def nz_hardcode_2(route)
    result = {
      'city': 'Queenstown',
      'country': 'New Zealand',
      'hotel': {
        'name': 'Sofitel Queenstown Hotel & Spa',
        'room_type': 'Superior Room',
        'no_of_people_per_room': 2,
        'price': 300.31,
        'description': 'Located in the heart of Queenstown, this luxurious 5-star hotel features elegant accommodations, a spa, a fitness center, and stunning views of the Remarkables mountain range.',
        'coordinates': {
          'latitude': -45.031249,
          'longitude': 168.662643
        }
      },
      'activity1': {
        'name': 'Skyline Queenstown',
        'price': 46.45,
        'description': 'Enjoy breathtaking views of Queenstown and the surrounding mountains from the Skyline gondola. Try the thrilling luge ride, have a delicious meal at the restaurant or take a scenic walk.',
        'coordinates': {
          'latitude': -45.021882,
          'longitude': 168.643035
        }
      },
      'activity2': {
        'name': 'Milford Sound',
        'price': 120.89,
        'description': 'Discover one of the most stunning natural wonders of New Zealand on a scenic cruise through Milford Sound. See towering waterfalls, snow-capped mountains, and playful dolphins.',
        'coordinates': {
          'latitude': -44.641682,
          'longitude': 167.897103
        }
      },
      'activity3': {
        'name': 'Arrowtown',
        'price': 0,
        'description': 'A quaint historic town located 20 minutes from Queenstown. Wander through the main street and take in the beautifully preserved architecture, boutique shops and dine on delicious local cuisine.',
        'coordinates': {
          'latitude': -44.9445,
          'longitude': 168.834
        }
      },
      'activity4': {
        'name': 'Queenstown Gardens',
        'price': 0,
        'description': 'Take a stroll in this beautiful public park where you can see a diverse range of flora, gardens, lawns, and walking tracks. You can also visit the heritage Queenstown Bowling Club and enjoy a game.',
        'coordinates': {
          'latitude': -45.032491,
          'longitude': 168.662665
        }
      }
    }

    days = 4

    4.times do |i|
      day = Day.new(route: route, city: "Queenstown")
      day.nation = result[:country]
      day.name_hotel = result[:hotel][:name]
      day.description_hotel = result[:hotel][:description]
      day.price_hotel = result[:hotel][:price]
      day.room_type = result[:hotel][:room_type]
      day.no_of_rooms = route.no_of_people.fdiv(result[:hotel][:no_of_people_per_room]).ceil
      day.latitude_hotel = result[:hotel][:coordinates][:latitude]
      day.longitude_hotel = result[:hotel][:coordinates][:longitude]

      day.name = result[:"activity#{i + 1}"][:name]
      day.description = result[:"activity#{i + 1}"][:description]
      day.price = result[:"activity#{i + 1}"][:price]
      day.latitude = result[:"activity#{i + 1}"][:coordinates][:latitude]
      day.longitude = result[:"activity#{i + 1}"][:coordinates][:longitude]
      day.sequence = days
      days += 1

      day.save
      # redirect_to route_path(route)


      route.total_price += ( day.price * route.no_of_people + day.price_hotel * day.no_of_rooms)

    end
  end

  def assign_destination_to_route(route, country_array)
    route.destination = country_array.join(", ")
    if route.save
      redirect_to route_path(route)
    end
  end
end
