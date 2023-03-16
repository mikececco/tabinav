import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change-hotel"
export default class extends Controller {
  static targets = [ "display" ]
  connect() {
    console.log("HEllo");
  }

  update(event) {
    event.preventDefault();
    // const hotelInfo = document.querySelectorAll("#hotel-info");
    // console.log(hotelInfo);

    // console.log(this.displayTarget.innerHTML);

    // console.log(event.currentTarget);
    // console.log("HELLO");
    const allDescriptions = document.querySelectorAll(".hotel_info")
    const url = event.currentTarget.action
    // console.log(allDescriptions)

    allDescriptions.forEach((description) => {
      description.innerHTML = `<div class="spinner-border" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>`
    })
    fetch(url, {
      method: "PATCH",
      headers: {"Accept": "text/plain"},
      body: new FormData(event.currentTarget)
    })
    .then(response => response.text())
    .then((data) => {
      allDescriptions.forEach((description) => {
        description.innerHTML = data
      })
      // this.displayTarget.innerHTML = data
    })
  }

  change(event) {
    event.preventDefault();
    // const hotelInfo = document.querySelectorAll("#hotel-info");
    // console.log(hotelInfo);

    // console.log(this.displayTarget.innerHTML);

    // console.log(event.currentTarget);
    // console.log("HELLO");
    console.log(event.currenTarget);
    const url = event.currentTarget.action
    // console.log(allDescriptions)

    event.currentTarget.innerHTML = `<div class="spinner-border" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>`

    fetch(url, {
      method: "PATCH",
      headers: {"Accept": "text/plain"},
      body: new FormData(event.currentTarget)
    })
    .then(response => response.text())
    .then((data) => {
      this.displayTarget.innerHTML = data
    })
  }
}
