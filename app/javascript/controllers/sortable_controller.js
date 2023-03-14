import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="sortable"
export default class extends Controller {
  connect() {
    const formValue = document.getElementById("day-order")

    Sortable.create(this.element, {
      ghostClass: "ghost",
      animation: 150,
      onEnd: () => {
        const liTags = document.querySelector(".day-order").querySelectorAll("li");
        const DAYMAP = new Map();

        let dayNum = 1
        liTags.forEach((day) => {
          DAYMAP.set(day.dataset.id, dayNum);
          dayNum += 1;
        })

        const obj = Object.fromEntries(DAYMAP);
        // console.log(obj)
        formValue.value = JSON.stringify(obj);

        // alert(`Day ${event.oldIndex + 1} moved to ${event.newIndex + 1}`)
      }
    })

  }

}
