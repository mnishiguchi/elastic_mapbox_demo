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
    console.log('instantiating PropertiesMap');

    this.sourceId = "properties"
    this.map      = this._createMap(lngLat);
    this.markers  = this._createMarkers(properties);

    this._setupEventListeners();
  }


  /**
   * Updates the markers on the map based on the specified properties json array.
   */
  updateMarkers(properties) {
    this.map.removeSource(this.sourceId);
    this.markers = this._createMarkers(properties);
    this._addMarkersOnMap();
  }


  // ---
  // PRIVATE METHODS
  // ---


  _setupEventListeners() {
    // Wait until the map is loaded.
    // Set up initial behavior of the map.
    this.map.on('load', () => {
      this._addMarkersOnMap();
    });

    // Show popup on click.
    this.map.on('click', (event) => {

      const markers = this.map.queryRenderedFeatures(event.point, {
          layers: ['properties']
      });

      if (!markers.length) {
          return;
      }

      // Populate the popup and set its coordinates
      // based on the feature found.
      new mapboxgl.Popup()
          .setLngLat(markers[0].geometry.coordinates)
          .setHTML(markers[0].properties.description)
          .addTo(this.map);
    });

    // Do something when user finish moving the map.
    this.map.on('moveend', () => {

      // TODO: do something.
      console.log("moveend: ", this.map.getCenter())

    });
  } // end _setupEventListeners


  /**
   * Create a map instance and render it on the #map element.
   * @param  {Array<Float>} initialCenterLngLat
   * @return {mapboxgl.Map} reference to the map object.
   */
  _createMap(initialCenterLngLat) {
    console.log('_createMap');

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
  _addMarkersOnMap() {
    // Add a GeoJSON source containing place coordinates and information.
    this.map.addSource(this.sourceId, {
        "type": "geojson",
        "data": {
            "type"    : "FeatureCollection",
            "features": this.markers
        }
    });

    // Add a layer showing the places based on the specified source.
    this.map.addLayer({
        "id"    : this.sourceId,
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
  _createMarkers(properties) {
    console.log(`_createMarkers`)

    let markers = [];
    for (let property of properties) {
      markers.push({
          "type": "Feature",
          "properties": {
              "description": property.description,
              "iconSize"   : [20, 20],
              "icon"       : "circle"
          },
          "geometry": {
              "type"       : "Point",
              "coordinates": property.lngLat
          }
      });
    }
    console.log(`  created markers: ${markers}`);

    return markers;
  }

} // endclass


module.exports = PropertiesMap;
