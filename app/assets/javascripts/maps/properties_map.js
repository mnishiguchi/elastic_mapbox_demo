// // Example params
// const lngLat = [ -77.356746, 38.957575 ];
// const properties = [
//   {
//     lngLat: [-77.356746, 38.957575],
//     description: `
//     <h4>Property 1</h4>
//     <p style="max-width: 150px; max-height: 300px; overflow-y: auto;">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
//     `
//   },
//   {
//     lngLat: [-77.321264, 38.943057],
//     description: `
//     <h4>Property 2</h4>
//     <p style="max-width: 150px; max-height: 300px; overflow-y: auto;">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
//     `
//   }
// ]
//
class PropertiesMap {

  constructor(lngLat, properties) {
    console.log('hello from properties_map.js');

    this.map      = this.createMap(lngLat);
    this.features = this.markerPoints(properties);

    this.setup();
  }


  setup() {
    // Wait until the map is loaded.
    // Set up initial behavior of the map.
    this.map.on('load', () => {
      this.addMarkersPointsOnMap();
    });

    // Show popup on click.
    this.map.on('click', (event) => {

      const features = this.map.queryRenderedFeatures(event.point, {
          layers: ['properties']
      });

      if (!features.length) {
          return;
      }

      // Populate the popup and set its coordinates
      // based on the feature found.
      new mapboxgl.Popup()
          .setLngLat(features[0].geometry.coordinates)
          .setHTML(features[0].properties.description)
          .addTo(this.map);
    });
  } // end setup


  /**
   * Create a map instance and render it on the #map element.
   * @param  {Array<Float>} initialCenterLngLat
   * @return {mapboxgl.Map} reference to the map object.
   */
  createMap(initialCenterLngLat) {
    console.log('createMap');

    // Create a map instance based on the specified initialCenterLngLat.
    return new window.mapboxgl.Map({
      container: 'map',
      style    : 'mapbox://styles/mapbox/light-v9',
      center   : initialCenterLngLat,
      zoom     : 10
    });
  }


  /**
   * @param {mapboxgl.Map} map
   * @param {Array<Object>} an array of markerpoint hashes
   */
  addMarkersPointsOnMap(markerPoints) {
    // Add a GeoJSON source containing place coordinates and information.
    this.map.addSource("properties", {
        "type": "geojson",
        "data": {
            "type"    : "FeatureCollection",
            "features": this.features
        }
    });

    // Add a layer showing the places based on the specified source.
    this.map.addLayer({
        "id"    : "properties",
        "type"  : "symbol",
        "source": "properties",
        "layout": {
            "icon-image"        : "{icon}-15",
            "icon-allow-overlap": true
        }
    });
  }


  /**
   * Converts the specified property objects into an array of marker point objects.
   * @param  {Array<Object>} properties an array of hashes with keys lngLat and description.
   * @return {Array<Object>} an array of markerpoint hashes
   */
  markerPoints(properties) {
    console.log(`markerPoints`)

    let markerPoints = [];
    for (let property of properties) {
      let marker = this.markerPoint(property.lngLat, property.description);
      markerPoints.push(marker);
    }

    return markerPoints;
  }


  /**
   * Creates a marker point for the specified lngLat with its description.
   * @param  {Array<Float>} lngLat
   * @param  {String} description
   * @return {Object}
   */
  markerPoint(lngLat, description) {
      console.log(`markerPoint: ${lngLat} | ${description}`);

      return {
          "type": "Feature",
          "properties": {
              "description": description,
              "iconSize"   : [20, 20],
              "icon"       : "circle"
          },
          "geometry": {
              "type"       : "Point",
              "coordinates": lngLat
          }
      }
  }
} // endclass


module.exports = PropertiesMap;
