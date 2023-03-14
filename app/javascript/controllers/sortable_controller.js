import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

const DAYMAP = new Map();

// Connects to data-controller="sortable"
export default class extends Controller {
  connect() {
    console.log("button inview 10")

    Sortable.create(this.element, {
      ghostClass: "ghost",
      animation: 150,
      onEnd: () => {
        const liTags = document.querySelector(".day-order").querySelectorAll("li");

        let dayNum = 1
        liTags.forEach((day) => {
          DAYMAP.set(day.dataset.id, dayNum);
          dayNum += 1;
        })
        // alert(`Day ${event.oldIndex + 1} moved to ${event.newIndex + 1}`)
      }
    })
  }

  update() {
    if (DAYMAP.size === 0) {
      console.log('please shuffle');
    } else {
      console.log(DAYMAP);
      // console.log(DAYMAP.get(''));
      DAYMAP.forEach((value, key) =>{
        fetch("/update_sequence", {
          method: "PATCH",
          headers: { "Accept": "application/json" },
          body: JSON.stringify(DAYMAP)
        })
          .then(response => response.json())
          .then((data) => {
            console.log(data)
          })

      })

    }


  }
}
