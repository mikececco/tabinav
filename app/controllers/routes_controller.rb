class RoutesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    if user_signed_in?
      @routes = current_user.routes
    else
      @routes = Route.all
    end
  end

  def show
    @route = Route.find(params[:id])
    @bookmark = Bookmark.new
    @days = @route.days.order(created_at: :asc)

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
      generate_days(@route)
    end
    Route.all.each do |route|
      route.destroy if @route.destination == nil
    end
  end

  private

  def route_params
    params.require(:route).permit(:budget, :start_date, :end_date, :destination, :no_of_people, :hotel_pref)
  end

  def generate_days(route)
    destination = route.destination == "" ? Route.all.sample.days.sample.city : route.destination
    route.no_of_people = 2 if route.no_of_people == nil

    rooms = route.no_of_people.fdiv(2).ceil
    no_of_days = (route.end_date - route.start_date + 1).to_i
    hotel_price = (route.budget - (15 * route.no_of_people * no_of_days)) / no_of_days / rooms
    hotel_description = case route.budget / rooms / route.no_of_people
      when 0...30 then "Choose a hostel to stay."
      when 300..1000 then "Choose a 5-star hotel."
      else "Choose a hotel with price from €#{hotel_price * 0.9} to €#{hotel_price}."
    end

    ["luxury hotel", "3-star hotel", "cheapest accommodation"].sample
    country_array = []

    # with price less than €#{route.budget / no_of_days - 20 * no_of_people}.
    # Choose #{@route.hotel_pref}.
    # I would like to stay 3 days in one city.

    no_of_cities = case no_of_days
      when 1..4 then 1
      when 5..7 then 2
      when 8..10 then 3
      else (no_of_days / 3).floor
    end
    @cities = ChatgptService.call("
      I want to go on a vacation in #{destination}.
      Suggest #{no_of_cities} cities around to visit.
      Respond with just the entire response in JSON with the value in an array of #{no_of_days} elements.
      Example response for 3 cities with a total of 8 days:
      [
        { 'city'=>'Amsterdam', 'days'=> 3 },
        { 'city'=>'Rotterdam', 'days'=> 3 },
        { 'city'=>'Brussels', 'days'=> 2 }
      ]")

      JSON.parse(@cities).each do |hash|
        hotel = ChatgptService.call("
          #{hotel_description} in #{hash["city"]}, convert all prices to euro.
          Include coordinates of the places recommended.
          Specify the country.
          Use only english language.
          Keep the description of the place within 250-300 characters.
          Be creative and inspire me.
          Respond with just the entire response in JSON.
          Example response:
          [{
            'hotel': {
              'name': 'Crowne Plaza Amsterdam Zuid',
              'country':'Netherlands',
              'room_type': 'Twin Room',
              'no_of_people_per_room': 2,
              'price': 110,
              'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
              'coordinates': {
                'latitude': 56.358468,
                'longitude': 4.881119
              }
            }
          }]
        ")

        hotel = JSON.parse(hotel).first["hotel"]

        hash["days"].times do |i|
          day = Day.new(route: route, city: hash["city"])
          day.nation = hotel["country"]
          day.name_hotel = hotel["name"]
          day.description_hotel = hotel["description"]
          day.price_hotel = hotel["price"]
          day.room_type = hotel["room_type"]
          day.no_of_rooms = route.no_of_people.fdiv(hotel["no_of_people_per_room"]).ceil
          day.latitude_hotel = hotel["coordinates"]["latitude"]
          day.longitude_hotel = hotel["coordinates"]["longitude"]

          activity = ChatgptService.call("
            Suggest place to visit in #{day.city}, convert all prices to euro.
            Include coordinates of the places recommended.
            Use only english language.
            Keep the description of the place within 250-300 characters.
            Be creative and inspire me.
            Respond with just the entire response in JSON.
            Example response:
            [{
              'activity': {
                'name': 'Grand Place',
                'price': 0,
                'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
                'coordinates': {
                  'latitude': 52.358468,
                  'longitude': 4.881119
                }
              }
            }]
          ")

          activity = JSON.parse(activity).first["activity"]

          day.name = activity["name"]
          day.description = activity["description"]
          day.price = activity["price"]
          day.latitude = activity["coordinates"]["latitude"]
          day.longitude = activity["coordinates"]["longitude"]

          day.save

        end

      end

      redirect_to route_path(route)
      # day.nation = hash.values[0]["country"]
      # day.name_hotel = hash.values[0]["hotel"]["name"]
      # day.description_hotel = hash.values[0]["hotel"]["description"]
      # day.price_hotel = hash.values[0]["hotel"]["price"]
      # day.room_type = hash.values[0]["hotel"]["room_type"]
      # day.no_of_rooms = route.no_of_people.fdiv(hash.values[0]["hotel"]["no_of_people_per_room"]).ceil
      # day.latitude_hotel = hash.values[0]["hotel"]["coordinates"]["latitude"]
      # day.longitude_hotel = hash.values[0]["hotel"]["coordinates"]["longitude"]
      # day.save


    # I will be departing the #{route.start_date} and leaving on the #{route.end_date}.
    # The itinerary will be #{no_of_days} days long.
    #   Give practical itinerary. Take travelling time into account.
    #   Suggest places to visit, convert all prices to euro.
    #   #{hotel_description}
    #   Same accommodation in the same city.
    #   Include coordinates of the places recommended.
    #   Specify the city and country.
    #   Use only english language.
    #   Keep the description of the place within 250-300 characters.
    #   Be creative and inspire me.
    #   Respond with just the entire response in JSON.
    #   Example response for 2 stops:
    #   [
    #     {'day1': {
    #       'city': 'Amsterdam',
    #       'country':'Netherlands',
    #       'activity': {
    #         'name': 'Van Gogh Museum',
    #         'price': 20,
    #         'description': 'The Van Gogh Museum is an art museum dedicated to the works of Vincent van Gogh and his contemporaries in Amsterdam in the Netherlands.',
    #         'coordinates': {
    #         'latitude': 52.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #       'hotel': {
    #         'name': 'Crowne Plaza Amsterdam Zuid',
    #         'room_type': 'Twin Room',
    #         'no_of_people_per_room': 2,
    #         'price': 110,
    #         'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
    #         'coordinates': {
    #         'latitude': 56.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #     }}, {
    #     'day2': {
    #       'city': 'Amsterdam',
    #       'country': 'Netherlands',
    #       'activity': {
    #         'name': 'Jordaan',
    #         'price': 0,
    #         'description': 'Jordaan is a district in the citycenter of Amsterdam, known for its beautiful houses, nice restaurants and original shops. On the many bridges over the canals, you can take beautiful pictures and see why Amsterdam is called the Venice of the North.',
    #         'coordinates': {
    #         'latitude': 52.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #       'hotel': {
    #         'name': 'Crowne Plaza Amsterdam Zuid',
    #         'room_type': 'Twin Room',
    #         'no_of_people_per_room': 2,
    #         'price': 110,
    #         'description': '5 star hotel located in the east of Amsterdam, it has a lively bar, a private garden, a restaurant and a terrace. It is within walking distance of many restaurants, bars and clubs.',
    #         'coordinates': {
    #         'latitude': 56.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #     }}, {
    #     'day3': {
    #       'city': 'Brussels',
    #       'country': 'Belgium',
    #       'activity': {
    #         'name': 'Grand Place',
    #         'price': 0,
    #         'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
    #         'coordinates': {
    #         'latitude': 52.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #       'hotel': {
    #         'name': 'Sleep Well Youth Hostel',
    #         'room_type': 'Single bed in Dormitory',
    #         'no_of_people_per_room': 1,
    #         'price': 25,
    #         'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
    #         'coordinates': {
    #         'latitude': 56.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #     }}, {
    #     'day4': {
    #       'city': 'Brussels',
    #       'country': 'Belgium',
    #       'activity': {
    #         'name': 'Grand Place',
    #         'price': 0,
    #         'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
    #         'coordinates': {
    #         'latitude': 52.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #       'hotel': {
    #         'name': 'Sleep Well Youth Hostel',
    #         'room_type': 'Single bed in Dormitory',
    #         'no_of_people_per_room': 1,
    #         'price': 25,
    #         'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
    #         'coordinates': {
    #         'latitude': 56.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #     }}, {
    #     'day5': {
    #       'city': 'Brussels',
    #       'country': 'Belgium',
    #       'activity': {
    #         'name': 'Grand Place',
    #         'price': 0,
    #         'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
    #         'coordinates': {
    #         'latitude': 52.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #       'hotel': {
    #         'name': 'Sleep Well Youth Hostel',
    #         'room_type': 'Single bed in Dormitory',
    #         'no_of_people_per_room': 1,
    #         'price': 25,
    #         'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
    #         'coordinates': {
    #         'latitude': 56.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #     }}, {
    #     'day6': {
    #       'city': 'Brussels',
    #       'country': 'Belgium',
    #       'activity': {
    #         'name': 'Grand Place',
    #         'price': 0,
    #         'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
    #         'coordinates': {
    #         'latitude': 52.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #       'hotel': {
    #         'name': 'Sleep Well Youth Hostel',
    #         'room_type': 'Single bed in Dormitory',
    #         'no_of_people_per_room': 1,
    #         'price': 25,
    #         'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
    #         'coordinates': {
    #         'latitude': 56.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #     }}, {
    #     'day7': {
    #       'city': 'Brussels',
    #       'country': 'Belgium',
    #       'activity': {
    #         'name': 'Grand Place',
    #         'price': 0,
    #         'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
    #         'coordinates': {
    #         'latitude': 52.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #       'hotel': {
    #         'name': 'Sleep Well Youth Hostel',
    #         'room_type': 'Single bed in Dormitory',
    #         'no_of_people_per_room': 1,
    #         'price': 25,
    #         'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
    #         'coordinates': {
    #         'latitude': 56.358468,
    #         'longitude': 4.881119
    #         }
    #       }
    #     }}]
    #   Respond just with the JSON.
    # ")
    # @response = JSON.parse(@response)

    # @response.each do |hash|
    #   day = Day.new(route: route)

    #   day.name = hash.values[0]["activity"]["name"]
    #   day.description = hash.values[0]["activity"]["description"]
    #   day.price = hash.values[0]["activity"]["price"]
    #   day.latitude = hash.values[0]["activity"]["coordinates"]["latitude"]
    #   day.longitude = hash.values[0]["activity"]["coordinates"]["longitude"]
    #   day.city = hash.values[0]["city"]
    #   day.nation = hash.values[0]["country"]
    #   day.name_hotel = hash.values[0]["hotel"]["name"]
    #   day.description_hotel = hash.values[0]["hotel"]["description"]
    #   day.price_hotel = hash.values[0]["hotel"]["price"]
    #   day.room_type = hash.values[0]["hotel"]["room_type"]
    #   day.no_of_rooms = route.no_of_people.fdiv(hash.values[0]["hotel"]["no_of_people_per_room"]).ceil
    #   day.latitude_hotel = hash.values[0]["hotel"]["coordinates"]["latitude"]
    #   day.longitude_hotel = hash.values[0]["hotel"]["coordinates"]["longitude"]
    #   day.save

    #   country_array << day.nation unless country_array.include?(day.nation)
    #   @route.total_price += ( day.price * route.no_of_people + day.price_hotel * day.no_of_rooms)
    # end
    # assign_destination_to_route(route, country_array)
  end

  def assign_destination_to_route(route, country_array)
    route.destination = country_array.join(" | ")
    if route.save
      redirect_to route_path(route)
    end
  end
end
