import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

export default class extends Controller {
  connect() {
    new Typed(this.element, {
      strings: ["Tabinav is cool", "AImazing trips"],
      typeSpeed: 50,
      loop: true
    })
  }
}


// import { Controller } from "@hotwired/stimulus"
// import Typed from "typed.js"

// export default class extends Controller {
//   static targets = ["text"]

//   connect() {
//     this.typed = new Typed(this.textTarget, {
//       strings: ["Tabinav is Cool", "AImazing Trips"],
//       typeSpeed: 50,
//       loop: true
//     })

//     this.pause = this.pause.bind(this)
//     this.resume = this.resume.bind(this)

//     this.element.addEventListener("mouseenter", this.pause)
//     this.element.addEventListener("mouseleave", this.resume)
//   }

//   pause() {
//     if (this.typed && typeof this.typed.pause === 'function') {
//       this.typed.pause()
//     } else {
//       console.error('Typed instance is not defined or pause method is not a function')
//     }
//   }

//   resume() {
//     if (this.typed && typeof this.typed.start === 'function') {
//       this.typed.start()
//     } else {
//       console.error('Typed instance is not defined or start method is not a function')
//     }
//   }
// }
