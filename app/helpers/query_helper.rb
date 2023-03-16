@response = ChatgptService.call("
      I want to go on a vacation in #{destination} and #{(no_of_days / 4).floor} nearby cities.
      I will be departing the #{route.start_date} and leaving on the #{route.end_date}.
      The itinerary will be #{no_of_days} days long.
      Give practical itinerary. Take travelling time into account.
      Suggest places to visit, convert all prices to euro.
      #{hotel_description}
      Same accommodation in the same city.
      Include coordinates of the places recommended.
      Specify the city and country.
      Use only english language.
      Keep the description of the place within 250-300 characters.
      Be creative and inspire me.
      Respond with just the entire response in JSON.
      Example response for 2 stops:
      [
        {'day1': {
          'city': 'Amsterdam',
          'country':'Netherlands',
          'activity': {
            'name': 'Van Gogh Museum',
            'price': 20,
            'description': 'The Van Gogh Museum is an art museum dedicated to the works of Vincent van Gogh and his contemporaries in Amsterdam in the Netherlands.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
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
          }
        }}, {
        'day2': {
          'city': 'Amsterdam',
          'country': 'Netherlands',
          'activity': {
            'name': 'Jordaan',
            'price': 0,
            'description': 'Jordaan is a district in the citycenter of Amsterdam, known for its beautiful houses, nice restaurants and original shops. On the many bridges over the canals, you can take beautiful pictures and see why Amsterdam is called the Venice of the North.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
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
          }
        }}, {
        'day3': {
          'city': 'Brussels',
          'country': 'Belgium',
          'activity': {
            'name': 'Grand Place',
            'price': 0,
            'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
          'hotel': {
            'name': 'Sleep Well Youth Hostel',
            'room_type': 'Single bed in Dormitory',
            'no_of_people_per_room': 1,
            'price': 25,
            'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
            'coordinates': {
            'latitude': 56.358468,
            'longitude': 4.881119
            }
          }
        }}, {
        'day4': {
          'city': 'Brussels',
          'country': 'Belgium',
          'activity': {
            'name': 'Grand Place',
            'price': 0,
            'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
          'hotel': {
            'name': 'Sleep Well Youth Hostel',
            'room_type': 'Single bed in Dormitory',
            'no_of_people_per_room': 1,
            'price': 25,
            'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
            'coordinates': {
            'latitude': 56.358468,
            'longitude': 4.881119
            }
          }
        }}, {
        'day5': {
          'city': 'Brussels',
          'country': 'Belgium',
          'activity': {
            'name': 'Grand Place',
            'price': 0,
            'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
          'hotel': {
            'name': 'Sleep Well Youth Hostel',
            'room_type': 'Single bed in Dormitory',
            'no_of_people_per_room': 1,
            'price': 25,
            'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
            'coordinates': {
            'latitude': 56.358468,
            'longitude': 4.881119
            }
          }
        }}, {
        'day6': {
          'city': 'Brussels',
          'country': 'Belgium',
          'activity': {
            'name': 'Grand Place',
            'price': 0,
            'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
          'hotel': {
            'name': 'Sleep Well Youth Hostel',
            'room_type': 'Single bed in Dormitory',
            'no_of_people_per_room': 1,
            'price': 25,
            'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
            'coordinates': {
            'latitude': 56.358468,
            'longitude': 4.881119
            }
          }
        }}, {
        'day7': {
          'city': 'Brussels',
          'country': 'Belgium',
          'activity': {
            'name': 'Grand Place',
            'price': 0,
            'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
            'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
            }
          }
          'hotel': {
            'name': 'Sleep Well Youth Hostel',
            'room_type': 'Single bed in Dormitory',
            'no_of_people_per_room': 1,
            'price': 25,
            'description': 'Located in the heart of Brussels, 10 minutes’ walk from Grand Place and Gare du Nord and 100m from the Rogier Metro Station and a shopping center, Sleep Well is the ideal starting point to explore the European capital. All rooms are fully renovated and equipped with bathroom and private toilet.',
            'coordinates': {
            'latitude': 56.358468,
            'longitude': 4.881119
            }
          }
        }}]
      Respond just with the JSON.
    ")
    @response = JSON.parse(@response)

    @response.each do |hash|
      day = Day.new(route: route)

      day.name = hash.values[0]["activity"]["name"]
      day.description = hash.values[0]["activity"]["description"]
      day.price = hash.values[0]["activity"]["price"]
      day.latitude = hash.values[0]["activity"]["coordinates"]["latitude"]
      day.longitude = hash.values[0]["activity"]["coordinates"]["longitude"]
      day.city = hash.values[0]["city"]
      day.nation = hash.values[0]["country"]
      day.name_hotel = hash.values[0]["hotel"]["name"]
      day.description_hotel = hash.values[0]["hotel"]["description"]
      day.price_hotel = hash.values[0]["hotel"]["price"]
      day.room_type = hash.values[0]["hotel"]["room_type"]
      day.no_of_rooms = route.no_of_people.fdiv(hash.values[0]["hotel"]["no_of_people_per_room"]).ceil
      day.latitude_hotel = hash.values[0]["hotel"]["coordinates"]["latitude"]
      day.longitude_hotel = hash.values[0]["hotel"]["coordinates"]["longitude"]
      day.save
    end
    assign_destination_to_route(route, country_array)


  def assign_destination_to_route(route, country_array)
    route.destination = country_array.join(" | ")
    if route.save
      redirect_to route_path(route)
    end
  end
