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
class PropertiesMap {

    constructor(lngLat, properties) {
        console.log('instantiating PropertiesMap');

        this.sourceId    = "properties"
        this.mapboxglMap = this._createMap(lngLat);
        this.markers     = this._createMarkers(properties);

        this._setupEventListeners();
    }


    /**
     * Updates the markers on the map based on the specified properties json array.
     */
    updateMap(lnglat, properties) {
        this._updateMarkers(properties);
        this._updateCenter(lnglat);
    }


    // ---
    // PRIVATE METHODS
    // ---


    _setupEventListeners() {
        // Wait until the map is loaded.
        // Set up initial behavior of the map.
        this.mapboxglMap.on('load', () => {
           this._addMarkersOnMap();
        });

        // Show popup on click.
        this.mapboxglMap.on('click', (event) => {

          const markers = this.mapboxglMap.queryRenderedFeatures(event.point, {
              layers: ['properties']
          });

          // Pan the map view to the clicked location.
          this.mapboxglMap.panTo(event.lngLat)

          if (markers.length) {
              // Populate the popup and set its coordinates
              // based on the feature found.
              new mapboxgl.Popup()
                  .setLngLat(markers[0].geometry.coordinates)
                  .setHTML(markers[0].properties.description)
                  .addTo(this.mapboxglMap);
          }
        });

        // Do something when user finish moving the map.
        this.mapboxglMap.on('moveend', () => {

            // TODO: do something.
            console.log("moveend: ", this.mapboxglMap.getCenter())

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
        this.mapboxglMap.addSource(this.sourceId, {
            "type": "geojson",
            "data": {
                "type"    : "FeatureCollection",
                "features": this.markers
            }
        });

        // Add a layer showing the places based on the specified source.
        this.mapboxglMap.addLayer({
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

    /**
     * Removes all existing markers and adds new markers.
     * @param  {Array<Object>} properties an array of hashes with keys lngLat and description.
     */
    _updateMarkers(properties) {
        this.mapboxglMap.removeSource(this.sourceId);
        this.markers = this._createMarkers(properties);
        this._addMarkersOnMap();
    }

    /**
     * Moves the center of the map to the specified lngLat.
     * @param  {Array<Float>} initialCenterLngLat
     */
    _updateCenter(lnglat) {
        this.mapboxglMap.panTo(lnglat);
    }

} // endclass


module.exports = PropertiesMap;
