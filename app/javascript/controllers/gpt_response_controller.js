import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gpt-response"
export default class extends Controller {
  static targets = ["nations", "cities", "card", "cardcont"]

  connect() {
    console.log("mike mike")
    let text = `
    I want to go on a vacation in Paris.
    Suggest 4 cities around to visit.
    Specify the country.
    Respond with just the entire response in JSON with a total of 4 days.
    Example response for 3 cities with a total of 8 days:
    [
      { 'city'=>'Amsterdam', 'country'=> 'Netherlands', 'days'=> 3 },
      { 'city'=>'Rotterdam', 'country'=> 'Netherlands', 'days'=> 3 },
      { 'city'=>'Brussels', 'country'=> 'Belgium', 'days'=> 2 }
    ]
    Respond just with the JSON.`

    const url = 'https://api.openai.com/v1/chat/completions'
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer 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"
    }
    const body = JSON.stringify({
      "model": 'gpt-3.5-turbo',
      "messages": [{ role: 'user', content: text }]
    })

    fetch(url, {
      method: "POST",
      headers,
      body,
    }).then(response => response.json())
    .then(data => {
      this.addNationsToLabel(data);
      this.addCitiesToList(data);
      console.log("Making second request");
      this.getHotelPrice();
      console.log("Making third request");
      this.generateCities();
    })
  }

  addNationsToLabel(data){
    let resp = data['choices'][0]['message']['content'];
    resp = JSON.parse(resp);
    // nationsTargets.insertAdjacentHTML('afterbegin', )
    resp.forEach((obj) => {
      let nationDiv = `<div class="inline-block px-2 py-1 mr-2 mb-2 px-3 py-1 leading-none bg-orange-200 text-orange-800 rounded-full font-semibold uppercase tracking-wide text-xs">${obj['country']}</div>`;
      this.nationsTarget.insertAdjacentHTML('afterbegin', nationDiv);
    })
  }
  // .then(data => console.log(data['choices'][0]['message']['content']));
  // .then(data => this.nationsTarget.innerText = data['choices'][0]['message']['content'][0]['city'])
  addCitiesToList(data){
    if (!data || !data.choices) {
      console.error('Invalid data format');
      return;
    }

    let resp = data['choices'][0]['message']['content'];
    resp = JSON.parse(resp);

    resp.forEach((element, index) => {
      let citiesList = `<li class="text-lg font-semibold">Day ${index + 1} - ${element['city']}, ${element['country']}</li>`
      this.citiesTarget.insertAdjacentHTML('beforeend', citiesList);
    })

    //---------
    resp.forEach((element, index) => {
      // console.log("dfdafdf")
      let card = `<div class=" border-b-2 rounded-lg mb-10 flex p-8 hover:shadow-2xl hover:scale-110 transition duration-1000 ease-in-out">
      <div class="w-1/2">
        <h4 class="text-2xl font-semibold mb-2">Day ${index + 1} - ${element['city']}, ${element['country']}</h4>
        <h4 class="text-lg font-medium mb-2 mydays"></h4>
        <p class="text-gray-600 mb-2"><i><%= day.description %></i></p>
        <p class="text-gray-600 font-medium"><%= day.price == 0 ? "No entrance fee" : "Entrance fee per head: €#{day.price}" %></p>
        <br>
        <div class="flex justify-between bg-darYellow" >
          <h4 class="text-lg font-medium mb-2">Accommodation: <br class="dayNameHotel"><%= day.name_hotel %> (<%= day.no_of_rooms %> x <%= day.room_type %>)</h4>
          <div class="pt-2" >
            <p class="text-gray-600 font-medium text-end px-3">Price: €<%= day.price_hotel %></p>
            <%= simple_form_for day do |f| %>
              <%= f.submit "Upgrade accommodation", class: "text-xs cursor-pointer transition duration-500 ml-10 px-3 py-2 text-mainYellow rounded-lg hover:bg-darkerYellow hover:text-white focus:outline-none" %>
            <% end %>
            </div>
          </div>
          <p class="text-gray-600 mb-2"><i class="dayHotel"></i></p>
        </div>
        <div class="w-1/2 flex justify-end">
          <div class="rounded-lg shadow-lg p-6 h-3/4">
            <img src="https://source.unsplash.com/random/1200x800/?<%= day.city %>" alt="Image of city" width="300" height="300" class="">
            <%# <p class="text-sm text-center pt-8"><i>Pic of <%= day.city %>
          </div>
        </div>
      </div>`

      this.cardcontTarget.insertAdjacentHTML("beforeend", card)
    })

    resp.forEach((obj, index) => {
      const mydays = document.querySelectorAll(".mydays")
      mydays[index].innerText = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    })

    //-----------------------
  }

  getHotelPrice(){
    let text = `
    Name any 3-star hotel in Paris.
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
    Respond just with the JSON.`

    const url = 'https://api.openai.com/v1/chat/completions'
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer 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"
    }
    const body = JSON.stringify({
      "model": 'gpt-3.5-turbo',
      "messages": [{ role: 'user', content: text }]
    })

    fetch(url, {
      method: "POST",
      headers,
      body,
    }).then(response => response.json())
    .then(data =>
      {
      this.addCard(data);
    }
    )
  }

  generateDays(){
    let text = `
    Name any 3-star hotel in Paris.
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
    Respond just with the JSON.`

    const url = 'https://api.openai.com/v1/chat/completions'
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer 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"
    }
    const body = JSON.stringify({
      "model": 'gpt-3.5-turbo',
      "messages": [{ role: 'user', content: text }]
    })

    fetch(url, {
      method: "POST",
      headers,
      body,
    }).then(response => response.json())
    .then(data =>
      {
      this.addCard(data);
    }
    )
  }

  addCard(data){
    let resp = data['choices'][0]['message']['content'];
    resp = JSON.parse(resp);
    resp.forEach(obj => {
      const dayHotel = document.querySelectorAll(".dayHotel")
      dayHotel.innerText = obj['name']
    })
  }

  generateCities(){
    let city = `
      Suggest 3 places to visit in Paris
      Choose a 2-star hotel, convert all prices to euro.
      Include coordinates of the places recommended.
      Use only english language.
      Keep the description of the place within 250-300 characters.
      Be creative and inspire me.
      Respond with just the entire response in JSON.
      Example response:
      [{
        'city': 'Paris',
        'country':'France',
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
        'activity3': {
          'name': 'Grand Place',
          'price': 0,
          'description': 'Much of the square's elegant character is due to the unique architecture of its elegant Gildehuizen (guild houses) with their magnificent gables, pilasters, and balustrades, ornately carved stonework, and rich gold decoration.',
          'coordinates': {
            'latitude': 52.358468,
            'longitude': 4.881119
          }
        }
      }]
      Respond just with the JSON.")`

      const url = 'https://api.openai.com/v1/chat/completions'
      const headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer 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"
      }
      const body = JSON.stringify({
        "model": 'gpt-3.5-turbo',
        "messages": [{ role: 'user', content: city }]
      })

      fetch(url, {
        method: "POST",
        headers,
        body,
      }).then(response => response.json())
      .then(data =>
        {
          console.log(data);
        this.addHotelInfo(data);
      }
      )
  }

  addHotelInfo(data){
    let resp = data['choices'][0]['message']['content'];
    resp = JSON.parse(resp);
    resp.forEach(obj => {
      const dayHotel = document.querySelectorAll(".dayNameHotel")
      dayHotel.innerText = obj['hotel']['name']
    })
  }
}
