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
      style: 'mapbox://styles/mapbox/navigation-night-v1',
      // zoom: 9, // starting zoom
      projection: 'globe'
    });
    this.map.setProjection('globe');

    this.#addMarkersToMap()
    this.#fitMapToMarkers()

    // this.#addRmarkersfirstToMap()

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
}
  // #addRmarkersfirstToMap() {
  //   this.rmarkersfirstValue.forEach((marker) => {
  //     const el = document.createElement('div');
  //     el.className = 'first';
  //     new mapboxgl.Marker(el)
  //       .setLngLat([ marker.lng, marker.lat ])
  //       .addTo(this.map)
  //   })
  // }
