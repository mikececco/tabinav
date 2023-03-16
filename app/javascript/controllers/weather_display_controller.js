import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="weather-display"
export default class extends Controller {

  static targets = ["city", "weather", "temp", "date"];

  connect() {
    // console.log("hello from weather controller!!!!!!!");
    const city = this.cityTarget.innerText;
    this.weatherTarget.innerHTML = '';
    this.tempTarget.innerHTML = '';

    this.searchCity(city);
  };

  searchCity(city) {
    const url = `http://api.openweathermap.org/geo/1.0/direct?q=${city}&limit=1&appid=${this.dateTarget.dataset.apiKey}&units=metric`;
    fetch(url)
      .then(response => response.json())
      .then((data) => {
        // console.log(data[0])
        const lat = data[0].lat;
        const lon = data[0].lon;
        this.searchWeather(lat, lon);
      })

  }

  searchWeather(lat, lon) {
    const date = this.dateTarget.innerText;
    const time = Date.parse(date).toString().substring(0,10)

    // const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=`;
    const url = `https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=${lat}&lon=${lon}&dt=${time}&appid=${this.dateTarget.dataset.apiKey}&units=metric`;
    fetch(url)
      .then(response => response.json())
      .then((data) => {
        // console.log(data);

        const weather = data.data[0].weather[0].main;
        // const iconId = data.data[0].weather[0].id;
        const temp = data.data[0].temp;


        this.weatherTarget.insertAdjacentHTML("beforeend", weather);
        // this.imgTarget.setAttribute("src", `https://openweathermap.org/img/w/${iconId}.png`)
      this.tempTarget.insertAdjacentHTML("beforeend", `Usually around ${temp.toFixed(0)}°C in ${new Date(date).toLocaleString('default', { month: 'long' })}`);
      });
  };
}
