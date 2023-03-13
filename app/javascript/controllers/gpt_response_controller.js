import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gpt-response"
export default class extends Controller {
  connect() {
    console.log("HELlo");

    const text = `
    I want to go on a trip around Amsterdam.
    I will be departing the 10th of March and leaving on the 15th of March.
    The itinerary will be #{no_of_days} days long.
    Give itinerary for each day. Take travelling time into account.
    Suggest places to visit, convert all prices to euro.
    Choose #{@route.hotel_pref}.
    Same hotel in the same city.
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
          'description': '5 star hotel with a sky bar and an indoor swimming pool.',
          'coordinates': {
          'latitude': 56.358468,
          'longitude': 4.881119
          }
        }
      }}]
    Respond just with the JSON.
  `

    console.log("HELlo");
    const url = 'https://api.openai.com/v1/chat/completions'
    fetch(url, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer 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"
      },
      body: JSON.stringify({
        "model": 'gpt-3.5-turbo',
        "messages": [{ role: 'user', content: text }]
      })
    }).then(response => response.text())
      .then((data) => {
        console.log(data);
      })

    console.log("HELlo");

  }
}
