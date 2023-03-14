import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change-list-color"
export default class extends Controller {
  static targets = [ "list" ]
  connect() {
    console.log("change color 8")
    const lists = document.querySelectorAll("li");
    console.log(lists);
    lists.forEach((list) => {
      console.log(list);
      list.addEventListener('mousedown', () => {
          list.classList.toggle("text-mainYellow");
      })

    });
  }

}
