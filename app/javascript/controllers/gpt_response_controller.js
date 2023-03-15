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
      'Authorization': "Bearer"
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
      // this.addNationsToLabel(data);
      this.addCitiesToList(data);
      // console.log("Making second request");
      // this.getHotelPrice();

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
        <h4 class="text-lg font-medium mb-2 mydays">HERE YOU NEED NAME OF THE DAY</h4>
        <p class="text-gray-600 mb-2"><i class="dayDescription">DESCRIPTION OF THE DAY</i></p>
        <p class="text-gray-600 font-medium priceDay">PRICE OF THE DAY<%= day.price == 0 ? "No entrance fee" : "Entrance fee per head: €#{day.price}" %></p>
        <br>
        <div class="flex justify-between bg-darYellow" >
          <h4 class="text-lg font-medium mb-2 dayNameHotel">Accommodation: <br>HOTEL NAME (NUMBER OF ROOMS<%= day.no_of_rooms %> x TYPE OF ROOM<%= day.room_type %>)</h4>
          <div class="pt-2 upgradeSubmit">
            <p class="text-gray-600 font-medium text-end px-3 priceHotel"></p>
              <form>
                <input type="submit" value="Upgrade accommodation" class="text-xs cursor-pointer transition duration-500 ml-10 px-3 py-2 text-mainYellow rounded-lg hover:bg-darkerYellow hover:text-white focus:outline-none">
              </form>
            </div>
          </div>
          <p class="text-gray-600 mb-2"><i class="dayHotel"></i></p>
        </div>
        <div class="w-1/2 flex justify-end">
          <div class="rounded-lg shadow-lg p-6 h-3/4 imageCity">
            INSERT PIC
          </div>
        </div>
      </div>`

      this.cardcontTarget.insertAdjacentHTML("beforeend", card)
    })

    const mydays = document.querySelectorAll(".imageCity")
    resp.forEach((obj, index) => {
      mydays[index].innerHTML = `<img src="https://source.unsplash.com/random/1200x800/?${obj['city']}" alt="Image of city" width="300" height="300">`
    })

    this.generateCities();
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
      'Authorization': "Bearer"
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
      'Authorization': "Bearer"
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
    resp.forEach((obj, index) => {
      console.log("INSERTING PRICE OF HOTEL");
      const myhotel = document.querySelectorAll(".priceHotel")
      myhotel[index].innerText = `Price: €${obj["price"]}`
    })

    // resp.forEach(obj => {
    //   const dayHotel = document.querySelectorAll(".dayHotel")
    //   dayHotel.innerText = obj['name']
    // })
    console.log("Making third request");
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
        'Authorization': "Bearer"
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
          console.log("Generating cities");
          this.addHotelInfo(data);
      }
      )
  }

  addHotelInfo(data){
    console.log("AddHotelInfo function");
    let resp = data['choices'][0]['message']['content'];
    resp = JSON.parse(resp);
    console.log("Inserting hotel name");

    const myhotel = document.querySelectorAll(".dayNameHotel")
    resp.forEach((obj, index) => {
      console.log(obj["hotel"]);
      myhotel[index].innerText = `Accommodation: <br>${obj["hotel"]["name"]} (${obj["hotel"]["no_of_people_per_room"]} x ${obj["hotel"]["room_type"]})`
    })
    // resp.forEach(obj => {
    //   const dayHotel = document.querySelectorAll(".dayNameHotel")
    //   dayHotel.innerText = obj['hotel']['name']
    // })
    console.log("Going to insert day name");
    const mydays = document.querySelectorAll(".mydays")
    resp.forEach((obj, index) => {
      console.log("Inserting activity name/day");
      mydays[index].innerText = obj[`activity${index+1}`]["name"]
    })

    const dayDescription = document.querySelectorAll(".dayDescription")
    resp.forEach((obj, index) => {
      console.log("Inserting day description");
      dayDescription[index].innerText = obj[`activity${index+1}`]["description"]
    })

    const priceDay = document.querySelectorAll(".priceDay")
    resp.forEach((obj, index) => {
      console.log("Inserting day hotel price");
      priceDay[index].innerText = `<%= ${obj[`activity${index+1}`]["price"]} == 0 ? "No entrance fee" : "Entrance fee per head: €${obj[`activity${index+1}`]["price"]}" %>`
    })
  }
}
