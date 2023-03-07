import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date"
export default class extends Controller {

  static targets = ["dateStart", "dateEnd"]

  connect() {
  }

  changeToCal(event) {
    // console.log(event.target.type);
    event.target.type = "date"
    // console.log(this.dateTarget);
    // this.dateStartTarget.type = "date"
  }
}
