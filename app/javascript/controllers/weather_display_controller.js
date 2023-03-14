import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="weather-display"
export default class extends Controller {

  static targets = ["city", "weather", "temp", "img", "date"];

  connect() {
    const city = this.cityTarget.innerText.match(/\-\s(.*),\s/)[1];
    this.weatherTarget.innerHTML = '';
    this.tempTarget.innerHTML = '';

    this.searchCity(city);
  };

  searchCity(city) {
    const url = `http://api.openweathermap.org/geo/1.0/direct?q=${city}&limit=1&appid=32d9d0ac2cd3da2a933c94ba2d172887`;
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

    // const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=32d9d0ac2cd3da2a933c94ba2d172887&units=metric`;
    const url = `https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=${lat}&lon=${lon}&dt=${time}&appid=32d9d0ac2cd3da2a933c94ba2d172887&units=metric`;
    fetch(url)
      .then(response => response.json())
      .then((data) => {
        console.log(data);

        const weather = data.data[0].weather[0].main;
        // const iconId = data.data[0].weather[0].id;
        const temp = data.data[0].temp;


        this.weatherTarget.insertAdjacentHTML("beforeend", weather);
        // this.imgTarget.setAttribute("src", `https://openweathermap.org/img/w/${iconId}.png`)
        this.tempTarget.insertAdjacentHTML("beforeend", `  ~${temp.toFixed(0)}°C`);
      });
  };
}
