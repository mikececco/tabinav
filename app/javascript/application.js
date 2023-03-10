// Entry point for the build script in your package.json

//=require_tree
import "@hotwired/turbo-rails"
import "./controllers"
import "flowbite"
import "flowbite/dist/flowbite.turbo.js";
import mapboxgl from 'mapbox-gl';
import { displayLogo } from "./searchanimation"

console.log("asfasf")

document.addEventListener("turbo:load", () => {
  const btn = document.querySelector(".form-submit")
  console.log(btn)
  btn.addEventListener("click", () => {
    displayLogo()
  })
})

//
// *= require mapbox-gl
// = require_tree .

// *= require mapbox-gl-geocoder

// let prevScrollpos = window.pageYOffset;
// window.onscroll = function() {
//   const currentScrollPos = window.pageYOffset;
//   if (prevScrollpos > currentScrollPos) {
//     document.getElementById("navbar").style.transform = "translateY(0)";
//   } else {
//     document.getElementById("navbar").style.transform = "translateY(-100%)";
//   }
//   prevScrollpos = currentScrollPos;
// }

$(document).ready(function() {
  // When hovering over the main content div, hide the navbar
  $('#main-content').hover(function() {
    $('#navbar').addClass('bg-darkerYellow');
    $('.navbar-element').addClass('opacity-0');
    $("#powered_by").removeClass('opacity-0');

    // $('#budgetInput').addClass('placeholder-black')
  }, function() {
    $('.navbar-element').removeClass('opacity-0');
    $('#navbar').removeClass('bg-darkerYellow');
    // $('#budgetInput').removeClass('placeholder-black')
    $("#powered_by").addClass('opacity-0');


  });
});
