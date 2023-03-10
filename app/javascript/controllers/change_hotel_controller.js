import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change-hotel"
export default class extends Controller {
  static targets = ["price", "hotel"]

  connect() {
    console.log(this.priceTarget)
    // console.log(this.hotelTarget)
  }

  update(event) {
    event.preventDefault()
    console.log(event)
  }
}
