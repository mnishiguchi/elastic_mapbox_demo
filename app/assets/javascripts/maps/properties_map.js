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

        this.markerSourceId = "properties";
        this.markerLayerId =  "properties-layer";
        this.countySourceId = "counties";
        this.countyLayerIds = [
          "counties-layer",
          "counties-layer-highlighted"
        ];
        this.mapboxglMap   = this._createMap(lngLat);
        this.markers       = this._createMarkers(properties);

        this._setupEventListeners();
    }


    /**
     * Updates the markers on the map based on the specified properties json array.
     */
    updateMap(lngLat, properties) {
        console.log("updateMap");
        this._updateMarkers(properties);
        this.updateCenter(lngLat);
    }


    /**
     * @return true if a marker exists at the specified lngLat.
     */
    isMarkerAtLngLat(lngLat) {
        return this._markersAtLngLat(lngLat).length > 0;
    }


    // ---
    // PRIVATE METHODS
    // ---


    _setupEventListeners() {

        // Wait until the map is loaded.
        // Set up initial behavior of the map.
        this.mapboxglMap.on('load', () => {
           this._addMarkerLayer();
           this._addCountyLayer();
        });


        // Show popup on click.
        this.mapboxglMap.on('click', (event) => {
            this._onClickMarker(event);
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
     */
    _addMarkerLayer() {
        // Add a GeoJSON source containing place coordinates and information.
        this.mapboxglMap.addSource(this.markerSourceId, {
            "type": "geojson",
            "data": {
                "type"    : "FeatureCollection",
                "features": this.markers
            }
        });
        this.mapboxglMap.addLayer({
            "id"    : this.markerLayerId,
            "type"  : "symbol",
            "source": this.markerSourceId,
            "layout": {
                "icon-image"        : "{icon}-15",
                "icon-allow-overlap": true
            }
        });
    }


    /**
     */
    _addCountyLayer() {
        this.mapboxglMap.addSource(this.countySourceId, {
            "type": "vector",
            "url": "mapbox://mapbox.82pkq93d"
        });
        this.mapboxglMap.addLayer({
            "id": this.countyLayerIds[0],
            "type": "fill",
            "source": this.countySourceId,
            "source-layer": "original",
            "paint": {
                "fill-outline-color": "rgba(0,0,0,0.1)",
                "fill-color": "rgba(0,0,0,0.1)"
            }
        }, 'place-city-sm'); // Place polygon under these labels.
        this.mapboxglMap.addLayer({
            "id": this.countyLayerIds[1],
            "type": "fill",
            "source": this.countySourceId,
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
        this.mapboxglMap.removeSource(this.markerSourceId);
        this.markers = this._createMarkers(properties);
        this._addMarkerLayer();
    }

    /**
     * Moves the center of the map to the specified lngLat.
     * @param  {Array<Float>} initialCenterLngLat
     */
    updateCenter(lngLat) {
        console.log("updateCenter");
        console.log(lngLat);
        this.mapboxglMap.panTo(lngLat);
    }


    _onClickMarker(event) {

        const markers = this._markersAtLngLat(event.point);

        if (markers.length) {
            // Populate the popup and set its coordinates
            // based on the feature found.
            new mapboxgl.Popup()
                .setLngLat(markers[0].geometry.coordinates)
                .setHTML(markers[0].properties.description)
                .addTo(this.mapboxglMap);
        }
    }

    _markersAtLngLat(lngLat) {
      return  this.mapboxglMap.queryRenderedFeatures(lngLat, {
          layers: [
            this.markerLayerId
          ]
      });
    }
} // endclass


module.exports = PropertiesMap;
