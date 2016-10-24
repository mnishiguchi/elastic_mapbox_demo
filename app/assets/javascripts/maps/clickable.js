module.exports = function() {

    console.log('hello from clickable');

    // Initiate the loading of a map and a popup.
    const map    = loadMap();
    const popup  = loadPopup();
    const canvas = map.getCanvasContainer();

    // Initial state.
    let state = {
        startPosition:   null,
        currentPosition: null,
        box:             null
    }


    /**
     * Loads a map from Mapbox GL API.
     * @return {mapboxgl.Map} A new map object.
     */
    function loadMap() {

        let map = new mapboxgl.Map({
            container: 'map',
            style: 'mapbox://styles/mapbox/streets-v9',
            center: [-98, 38.88],
            minZoom: 2,
            zoom: 3
        });

        // Disable default box zooming.
        map.boxZoom.disable();

        return map;
    }


    /**
     * Loads a popup object from Mapbox GL API.
     * @return {mapboxgl.Popup} A new popup object.
     */
    function loadPopup() {

        let popup =  new mapboxgl.Popup({
            closeButton: false
        });

        return popup;
    }


    /**
     * Decorates the specified map objects.
     * @param  {mapboxgl.Map}
     * @return {Null}
     */
    function decorateMap(map) {

        // Add the source to query. In this example we're using
        // county polygons uploaded as vector tiles
        map.addSource('counties', {
            "type": "vector",
            "url": "mapbox://mapbox.82pkq93d"
        });

        map.addLayer({
            "id": "counties",
            "type": "fill",
            "source": "counties",
            "source-layer": "original",
            "paint": {
                "fill-outline-color": "rgba(0,0,0,0.1)",
                "fill-color": "rgba(0,0,0,0.1)"
            }
        }, 'place-city-sm'); // Place polygon under these labels.

        map.addLayer({
            "id": "counties-highlighted",
            "type": "fill",
            "source": "counties",
            "source-layer": "original",
            "paint": {
                "fill-outline-color": "#484896",
                "fill-color": "#6e599f",
                "fill-opacity": 0.75
            },
            "filter": ["in", "FIPS", ""]
        }, 'place-city-sm'); // Place polygon under these labels.
    }


    // We start interacting with users moving mouse as soon as map is loaded.
    map.on('load', () => {

        decorateMap(map);

        // Set `true` to dispatch the event before other functions call it.
        // This is necessary for disabling the default map dragging behavior.
        canvas.addEventListener('mousedown', (event) => {

            // Continue the rest of the function if the shiftkey is pressed.
            if (!(event.button === 0)) {
                return;
            }

            // Disable default drag zooming when the shift key is held down.
            map.dragPan.disable();

            listenForMouse();
            captureStartPosition(event);

        }, true);


        /**
         * @param  {Array<mapboxgl.Point>} line An array of two points.
         */
        function captureFinishPosition(line) {

            unlistenForMouse();
            removeBox();

            // If line exists. use this value as the argument for `queryRenderedFeatures`
            if (line) {
                const features = map.queryRenderedFeatures(line, {
                  layers: ['counties']
                });

                if (features.length >= 1000) {
                    return window.alert('Select a smaller number of features');
                }

                // Run through the selected features and set a filter
                // to match features with unique FIPS codes to activate
                // the `counties-highlighted` layer.
                const filter = features.reduce((memo, feature) => {
                    memo.push(feature.properties.FIPS);
                    return memo;
                }, ['in', 'FIPS']);

                map.setFilter("counties-highlighted", filter);
            }

            map.dragPan.enable();
        }


        /**
         * Starts listening mouse motion.
         */
        function listenForMouse() {

            document.addEventListener('keydown', (event) => {
              // If the ESC key is pressed.
              if (event.keyCode === 27) {
                captureFinishPosition();
              }
            });

            document.addEventListener('mousemove', (event) => {
                captureCurrentPosition(event);
                createBox();
                updateBoxPosition();
            });

            document.addEventListener('mouseup', (event) => {
                let line = [ state.startPosition, mousePosition(event) ];
                captureFinishPosition(line);
            });
        }


        /**
         * Unregister eventlisteners for mouse motion.
         */
        function unlistenForMouse() {
            document.removeEventListener('keydown',   (event) => {});
            document.removeEventListener('mousemove', (event) => {});
            document.removeEventListener('mouseup',   (event) => {});
        }


        /**
         * Appends the box element if it doesnt exist.
         */
        function createBox() {
            if (!state.box) {
                state.box = document.createElement('div');
                state.box.classList.add('boxdraw');
                canvas.appendChild(state.box);
            }
        }


        /**
         * Removes the box div element and clears the reference to it.
         */
        function removeBox() {
            if (state.box) {
                state.box.parentNode.removeChild(state.box);
                state.box = null;
            }
        }


        /**
         * @param  {Event} event
         * @return {mapboxgl.Point} The xy coordinates of the mouse position.
         */
        function captureStartPosition(event) {
            state.startPosition = mousePosition(event);
        }


        /**
         * @param  {Event} event
         * @return {mapboxgl.Point} The xy coordinates of the mouse position.
         */
        function captureCurrentPosition(event) {
            state.currentPosition = mousePosition(event);
        }


        /**
         * @param  {Event} event
         * @return {mapboxgl.Point} The xy coordinates of the mouse position.
         */
        function mousePosition(event) {

            const rect = canvas.getBoundingClientRect();

            return new mapboxgl.Point(
                event.clientX - rect.left - canvas.clientLeft,
                event.clientY - rect.top - canvas.clientTop
            );
        }


        /**
         * Adjusts width and xy position of the box element ongoing.
         */
        function updateBoxPosition() {
            let minX = Math.min(state.startPosition.x, state.currentPosition.x),
                maxX = Math.max(state.startPosition.x, state.currentPosition.x),
                minY = Math.min(state.startPosition.y, state.currentPosition.y),
                maxY = Math.max(state.startPosition.y, state.currentPosition.y);

            let pos = 'translate(' + minX + 'px,' + minY + 'px)';
            state.box.style.transform       = pos;
            state.box.style.WebkitTransform = pos;
            state.box.style.width           = maxX - minX + 'px';
            state.box.style.height          = maxY - minY + 'px';
        }
    });
}
