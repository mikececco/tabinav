// app/javascript/controllers/flatpickr_controller.js
import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";

// Connects to data-controller="flatpickr"
export default class extends Controller {
  // Inform the controller that it has two targets in the form, which are our inputs
  static targets = [ "startDate", "endDate" ]

  connect() {
    console.log("Hello connected");
    flatpickr(this.startDateTarget, {})
    flatpickr(this.endDateTarget, {})
  }
}
