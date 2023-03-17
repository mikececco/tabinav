import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="animation"
export default class extends Controller {
  connect() {
    // console.log("connected with code")
    // // const loader = document.querySelector("#loading");
    // const search = document.querySelector(".searchbar")
    // const loader = document.getElementById("loading");

    // const addClass = () => {
    //   // console.log("remove")
    //   loader.classList.add("hidden");
    // }

    // function toggleDiv() {
    //   // console.log("click")
    //   loader.classList.remove("hidden");
    //   setTimeout(addClass, 20000);
    //   $.get('<%= some_named_route_path %>')
    //   }

    // search.addEventListener("click", toggleDiv)
  }
}
