import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change-hotel"
export default class extends Controller {
  static targets = [ "display" ]
  connect() {
    console.log('hiiii');
  }

  // update(event) {
  //   event.preventDefault();
  //   // const hotelInfo = document.querySelectorAll("#hotel-info");
  //   // console.log(hotelInfo);

  //   console.log(this.displayTarget.innerHTML);

  //   console.log(event.currentTarget);

  //   const url = event.currentTarget.action
  //   fetch(url, {
  //     method: "patch",
  //     headers: {"Accept": "text/plain"},
  //     body: new FormData(this.currentTarget)
  //   })
  //   .then(response => response.text())
  //   .then((data) => {
  //     console.log(data);
  //     // this.displayTarget.innerHTML = data
  //   })
  // }
}
