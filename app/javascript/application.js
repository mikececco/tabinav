// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
//
*= require mapbox-gl
= require_tree .

*= require mapbox-gl-geocoder
