import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gpt-response"
export default class extends Controller {
  static targets = ["nations", "cities"]

  connect() {
    console.log("HELlo");

    const text = `
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
    }).then(response => response.json())
    .then(data => this.addNationsToLabel(data))
    .then(data => this.addCitiesToList(data))
  }

      addNationsToLabel(data){
        let resp = data['choices'][0]['message']['content'];
        resp = JSON.parse(resp);
        // nationsTargets.insertAdjacentHTML('afterbegin', )
        resp.forEach((obj) => {
          let nationDiv = `<div class="inline-block px-2 py-1 mr-2 mb-2 px-3 py-1 leading-none bg-orange-200 text-orange-800 rounded-full font-semibold uppercase tracking-wide text-xs">${obj['country']}</div>`;
          this.nationsTarget.insertAdjacentHTML('afterbegin', nationDiv);
        })
        console.log("Finished with nations");
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
        console.log(resp);
        // nationsTargets.insertAdjacentHTML('afterbegin', )
        resp.forEach((element, index) => {
          console.log(element);
          let citiesList = `<li class="text-lg font-semibold">Day ${index + 1} - ${element['city']}, ${element['country']}</li>`
          this.citiesTarget.insertAdjacentHTML('afterbegin', citiesList);
        // this.citiesTarget.adjacentHTML("beforeend",data['choices'][0]['message']['content'][0]['city']
      })
    }
}
