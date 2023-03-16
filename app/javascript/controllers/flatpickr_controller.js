import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";
// Import the rangePlugin from the flatpickr library
import rangePlugin from "flatpickr/dist/plugins/rangePlugin";

// Connects to data-controller="flatpickr"
export default class extends Controller {
  static targets = [ "startDate", "endDate" ]
  connect() {
    // console.log("hello")
    flatpickr(this.startDateTarget, {
              // Provide an id for the plugin to work
              plugins: [new rangePlugin({ input: "#end_date"})]})
    flatpickr(this.endDateTarget, {})
  }
}
