import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

export default class extends Controller {
  connect() {
    console.log("hello")
    new Typed(this.element, {
      strings: ["Tabinav is the key. To unlock hidden gems. A world of adventure. A journey without end.", "With Tabinav as our guide. We venture into the unknown. A world of excitement and wonder. A journey like no other.", "Tabinav leads us on. A journey of discovery. We travel far and wide. With joy and wonder in our hearts."],
      typeSpeed: 50,
      loop: true
    })
  }
}
