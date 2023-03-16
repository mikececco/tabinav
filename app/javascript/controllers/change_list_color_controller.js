import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="change-list-color"
export default class extends Controller {

  connect() {
    const lists = document.querySelectorAll("li");

    lists.forEach((list) => {
      list.addEventListener('mousedown', () => {
          list.classList.toggle("text-mainYellow");
      })
    });
  }

}
