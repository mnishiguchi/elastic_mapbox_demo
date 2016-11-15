// // Example params
// const lngLat = [ -77.356746, 38.957575 ];
// const properties = [
//   {
//     lngLat: [-77.356746, 38.957575],
//     description: `
//     <h4>Property 1</h4>
//     <p">Lorem ipsum.</p>
//     `
//   },
//   {
//     lngLat: [-77.321264, 38.943057],
//     description: `
//     <h4>Property 2</h4>
//     <p">Lorem ipsum .</p>
//     `
//   }
// ]
//

const markerSourceId = "properties";
const markerLayerId  = "properties-layer";
const countySourceId = "counties";
const countyLayerIds = [
  "counties-layer",
  "counties-layer-highlighted"
];

let mapboxglMap   = null;
let markers       = null;


// ---
// PUBLIC INTERFACE
// ---


function initializePropertiesMap(lngLat, properties) {
    console.log('initializePropertiesMap');

    mapboxglMap   = createMap(lngLat);
    markers       = createMarkers(properties);

    setupEventListeners();

    // Expose public methods.
    return {
      isMarkerAtLngLat: isMarkerAtLngLat,
      mapboxglMap:      mapboxglMap,
      updateCenter:     updateCenter,
      updateMap:        updateMap,
    };
}


// ---
// PUBLIC FUNCTIONS
// ---


/**
 * @return true if a marker exists at the specified lngLat.
 */
function isMarkerAtLngLat(lngLat) {
    return markersAtLngLat(lngLat).length > 0;
}

/**
 * Moves the center of the map to the specified lngLat.
 * @param  {Array<Float>} initialCenterLngLat
 */
function updateCenter(lngLat) {
    console.log("updateCenter");
    console.log(lngLat);
    mapboxglMap.panTo(lngLat);
}

/**
 * Updates the markers on the map based on the specified properties json array.
 */
function updateMap(lngLat, properties) {
    console.log("updateMap");
    updateMarkers(properties);
    updateCenter(lngLat);
}


// ---
// PRIVATE FUNCTIONS
// ---


function setupEventListeners() {

    // Wait until the map is loaded.
    // Set up initial behavior of the map.
    mapboxglMap.on('load', () => {
       addMarkerLayer();
       addCountyLayer();
    });


    // Show popup on click.
    mapboxglMap.on('click', (event) => {
        onClickMarker(event);
    });


    // // Do something when user finish moving the map.
    // mapboxglMap.on('moveend', () => {
    //
    //     // TODO: do something.
    //     console.log("moveend: ", mapboxglMap.getCenter())
    //
    // });
} // end setupEventListeners

/**
 * Create a map instance and render it on the #map element.
 * @param  {Array<Float>} initialCenterLngLat
 * @return {mapboxgl.Map} reference to the map object.
 */
function createMap(initialCenterLngLat) {
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
 */
function addMarkerLayer() {
    // Add a GeoJSON source containing place coordinates and information.
    mapboxglMap.addSource(markerSourceId, {
        "type": "geojson",
        "data": {
            "type"    : "FeatureCollection",
            "features": markers
        }
    });
    mapboxglMap.addLayer({
        "id"    : markerLayerId,
        "type"  : "symbol",
        "source": markerSourceId,
        "layout": {
            "icon-image"        : "{icon}-15",
            "icon-allow-overlap": true
        }
    });
}

/**
 */
function addCountyLayer() {
    mapboxglMap.addSource(countySourceId, {
        "type": "vector",
        "url": "mapbox://mapbox.82pkq93d"
    });
    mapboxglMap.addLayer({
        "id": countyLayerIds[0],
        "type": "fill",
        "source": countySourceId,
        "source-layer": "original",
        "paint": {
            "fill-outline-color": "rgba(0,0,0,0.1)",
            "fill-color": "rgba(0,0,0,0.1)"
        }
    }, 'place-city-sm'); // Place polygon under these labels.
    mapboxglMap.addLayer({
        "id": countyLayerIds[1],
        "type": "fill",
        "source": countySourceId,
        "source-layer": "original",
        "paint": {
            "fill-outline-color": "#484896",
            "fill-color": "#6e599f",
            "fill-opacity": 0.75
        },
        "filter": ["in", "COUNTY", ""]
    }, 'place-city-sm'); // Place polygon under these labels.
}

/**
 * Converts the specified property objects into an array of marker point objects.
 * @param  {Array<Object>} properties an array of hashes with keys lngLat and description.
 * @return {Array<Object>} an array of markerpoint hashes
 */
function createMarkers(properties) {
    console.log(`createMarkers`)

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

/**
 * Removes all existing markers and adds new markers.
 * @param  {Array<Object>} properties an array of hashes with keys lngLat and description.
 */
function updateMarkers(properties) {
    mapboxglMap.removeSource(markerSourceId);
    markers = createMarkers(properties);
    addMarkerLayer();
}

function onClickMarker(event) {
    const markers = markersAtLngLat(event.point);

    if (markers.length) {
        // Populate the popup and set its coordinates
        // based on the feature found.
        new mapboxgl.Popup()
            .setLngLat(markers[0].geometry.coordinates)
            .setHTML(markers[0].properties.description)
            .addTo(mapboxglMap);
    }
}

function markersAtLngLat(lngLat) {
  return  mapboxglMap.queryRenderedFeatures(lngLat, {
      layers: [
        markerLayerId
      ]
  });
}

module.exports = initializePropertiesMap;
