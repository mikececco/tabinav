import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

export default class extends Controller {
  connect() {
    console.log("hello")
    new Typed(this.element, {
      strings: ["Tabinav is the key. To unlock hidden gems. A world of adventure. A journey without end.", "I am processing your inputs, may take a while.", "I am calling my fellow AI models to find something amazing for you.", "With Tabinav, a journey like no other.", "Looking for amazing cities...", "Looking for amazing hotels...", "Your budget, our AI, your dream trip", "Looking for amazing activities...", "Many information, let me reorder them better, wait a sec...", "Sorry bumped into my boss Sam, dropped my files...", "Joking hihihi, almost there!","Going back to my desk...", "Ok, days are almost done...", "Activities also...", "Looking for the current prices...", "Let's hope that Swiss bank does not collapse also...", "Sorry was thinking out loud...", ""],
      typeSpeed: 50,
      loop: true
    })
  }
}
