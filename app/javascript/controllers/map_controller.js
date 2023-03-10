import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
    rmarkersfirst: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    // console.log(this.rmarkersfirstValue)

    this.map = new mapboxgl.Map({
      container: this.element,
      style: 'mapbox://styles/mapbox/streets-v12',
      projection: 'globe',
      zoom: 1.5
    });
    this.map.setProjection('globe');
    this.#addMarkersToMap()
    this.#fitMapToMarkers()
    this.#addRmarkersfirstToMap()

    let markers_array = []
    this.markersValue.forEach(marker => markers_array.push([ marker.lng, marker.lat ]))

    this.map.on('load', () => {
      // console.log("pleaseee")
      this.map.setFog({
        range: [2, 8],
        'horizon-blend': 0.02, // Atmosphere thickness (default 0.2 at low zooms)
        color: 'rgb(186, 210, 235)', // Lower atmosphere
        'high-color': 'rgb(36, 92, 223)', // Upper atmosphere
        'space-color': 'rgb(11, 11, 25)', // Background color
        'star-intensity': 0.15,
      });
      this.map.addSource('route', {
          'type': 'geojson',
          'data': {
              'type': 'Feature',
              'properties': {},
              'geometry': {
                  'type': 'LineString',
                  'coordinates': markers_array
              }
          }
        });
        this.map.addLayer({
            'id': 'route',
            'type': 'line',
            'source': 'route',
            'layout': {
                'line-join': 'round',
                'line-cap': 'round'
            },
            'paint': {
                'line-color': '#ef8a2c',
                'line-width': 5
            }
        });
      })

    //       // At low zooms, complete a revolution every two minutes.
    // const secondsPerRevolution = 120;
    // // Above zoom level 5, do not rotate.
    // const maxSpinZoom = 5;
    // // Rotate at intermediate speeds between zoom levels 3 and 5.
    // const slowSpinZoom = 3;

    // let userInteracting = false;
    // let spinEnabled = true;

    // function spinGlobe() {
    // const zoom = map.getZoom();
    // if (spinEnabled && !userInteracting && zoom < maxSpinZoom) {
    // let distancePerSecond = 360 / secondsPerRevolution;
    // if (zoom > slowSpinZoom) {
    // // Slow spinning at higher zooms
    // const zoomDif =
    // (maxSpinZoom - zoom) / (maxSpinZoom - slowSpinZoom);
    // distancePerSecond *= zoomDif;
    // }
    // const center = map.getCenter();
    // center.lng -= distancePerSecond;
    // // Smoothly animate the map over one second.
    // // When this animation is complete, it calls a 'moveend' event.
    // map.easeTo({ center, duration: 1000, easing: (n) => n });
    // }
    // }

    // // Pause spinning on interaction
    // map.on('mousedown', () => {
    // userInteracting = true;
    // });

    // // Restart spinning the globe when interaction is complete
    // map.on('mouseup', () => {
    // userInteracting = false;
    // spinGlobe();
    // });

    // // These events account for cases where the mouse has moved
    // // off the map, so 'mouseup' will not be fired.
    // map.on('dragend', () => {
    // userInteracting = false;
    // spinGlobe();
    // });
    // map.on('pitchend', () => {
    // userInteracting = false;
    // spinGlobe();
    // });
    // map.on('rotateend', () => {
    // userInteracting = false;
    // spinGlobe();
    // });

    // // When animation is complete, start spinning if there is no ongoing interaction
    // map.on('moveend', () => {
    // spinGlobe();
    // });

    // document.getElementById('btn-spin').addEventListener('click', (e) => {
    // spinEnabled = !spinEnabled;
    // if (spinEnabled) {
    // spinGlobe();
    // e.target.innerHTML = 'Pause rotation';
    // } else {
    // map.stop(); // Immediately end ongoing animation
    // e.target.innerHTML = 'Start rotation';
    // }
    // });

    // spinGlobe();
  }

  #addMarkersToMap() {
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html) // Add this
      new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(popup) // Add this
        .addTo(this.map)
    });
  }
  // [...]
  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 25, duration: 0 })
  }

  #addRmarkersfirstToMap() {
    this.rmarkersfirstValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.first_marker_html) // Add this
      new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(popup) // Add this
        .addTo(this.map)
    });
  }
}
