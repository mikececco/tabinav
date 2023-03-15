import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="animation"
export default class extends Controller {
  connect() {
    console.log("connected with code")
    const loader = document.querySelector("#loading");
    const search = document.querySelector(".searchbar")

    // showing loading
    function displayLoading() {
        loader.classList.add("display");
        // to stop loading after some time
    }

    search.addEventListener("click", displayLoading)
  }
}
