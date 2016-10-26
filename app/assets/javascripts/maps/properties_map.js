// Example properties.
// TODO: generate this type list from search result.
const properties = [
  {
    lngLat: [-77.356746, 38.957575],
    description: `
    <h4>Property 1</h4>
    <p style="max-width: 150px; max-height: 300px; overflow-y: auto;">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
    `
  },
  {
    lngLat: [-77.321264, 38.943057],
    description: `
    <h4>Property 2</h4>
    <p style="max-width: 150px; max-height: 300px; overflow-y: auto;">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
    `
  }
]


const restonLngLat = [ -77.356746, 38.957575 ]


// ---
// ---


module.exports = function() {

  console.log('hello from properties_map.js');

  const map      = createMap(restonLngLat);
  const features = markerPoints(properties);

  // Wait until the map is loaded.
  map.on('load', () => {

      // Add a GeoJSON source containing place coordinates and information.
      map.addSource("properties", {
          "type": "geojson",
          "data": {
              "type": "FeatureCollection",
              "features": features
          }
      });

      // Add a layer showing the places based on the specified source.
      map.addLayer({
          "id": "properties",
          "type": "symbol",
          "source": "properties",
          "layout": {
              "icon-image": "{icon}-15",
              "icon-allow-overlap": true
          }
      });
  });


  map.on('click', (event) => {

      const features = map.queryRenderedFeatures(event.point, {
          layers: ['properties']
      });

      if (!features.length) {
          return;
      }

      // Populate the popup and set its coordinates
      // based on the feature found.
      const popup = new mapboxgl.Popup()
          .setLngLat(features[0].geometry.coordinates)
          .setHTML(features[0].properties.description)
          .addTo(map);
  });

}


// ---
// Private functions
// ---


/**
 * Create a map instance and render it on the #map element.
 * @param  {Array<Float>} initialCenterLngLat
 * @return {mapboxgl.Map} reference to the map object.
 */
function createMap(initialCenterLngLat) {
  console.log('createMap');

  // Default: Whitehouse
  initialCenterLngLat = initialCenterLngLat || [-77.036529, 38.897676];

  // Create a map instance based on the specified initialCenterLngLat.
  return new window.mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/light-v9',
    center: initialCenterLngLat,
    zoom: 12
  });
}


/**
 * Creates a marker point for the specified lngLat with its description.
 * @param  {Array<Float>} lngLat
 * @param  {String} description
 * @return {Object}
 */
function markerPoint(lngLat, description) {
    console.log(`markerPoint: ${lngLat} | ${description}`);

    return {
        "type": "Feature",
        "properties": {
            "description": description,
            "iconSize": [20, 20],
            "icon": "circle"
        },
        "geometry": {
            "type": "Point",
            "coordinates": lngLat
        }
    }
}


/**
 * Converts the specified property objects into an array of marker point objects.
 * @param  {Array<Object>} properties an array of hashes with keys lngLat and description.
 * @return {Array<Object>} an array of markerpoint hashes
 */
function markerPoints(properties) {
  console.log(`markerPoints:`)

  let markerPoints = [];
  for (let property of properties) {
    let marker = markerPoint(property.lngLat, property.description);
    markerPoints.push(marker);
  }

  return markerPoints;
}
