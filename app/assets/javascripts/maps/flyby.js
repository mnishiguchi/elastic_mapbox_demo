module.exports = function() {

  console.log('hello from flyby');

  var map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/light-v9',
      center: [-77.356746, 38.957575],
      zoom: 12
  });


  function add_point_to_map(center) {
      var el = document.createElement('div');
      el.className = 'marker';

      new mapboxgl.Marker(el)
          .setLngLat(center)
          .addTo(map);
  }

  function toolTipAdd(center) {
      var popup = new mapboxgl.Popup({
              closeOnClick: false
          })
          .setLngLat(center)
          .setHTML('<h1>Hello World!</h1>')
          .addTo(map);
  }

  $('.marker').on('click', function() {
      toolTipAdd(center);
  });


  //////////////////////////////////////////////////////////
  ///// GeoJSON for Listing Placement + Tooltip Info ///////
  //////////////////////////////////////////////////////////

  var markerPoints = []

  function coordinateToMarkerPoint(description, long, lat) {
      return {
          "type": "Feature",
          "properties": {
              "description": description,
              "iconSize": [20, 20],
              "icon": "circle"
          },
          "geometry": {
              "type": "Point",
              "coordinates": [long, lat]
          }
      }
  }

  $.each(listingData, function(index, listing_hash) {
      var marker = coordinateToMarkerPoint(listing_hash.description, listing_hash.long, listing_hash.lat);
      markerPoints.push(marker);
  });

  map.on('load', function() {
      // Add a GeoJSON source containing place coordinates and information.
      map.addSource("listings", {
          "type": "geojson",
          "data": {
              "type": "FeatureCollection",
              "features": markerPoints
          }
      });
      // Add a layer showing the places.
      map.addLayer({
          "id": "listings",
          "type": "symbol",
          "source": "listings",
          "layout": {
              "icon-image": "{icon}-15",
              "icon-allow-overlap": true
          }
      });
  });


  //////////////////////////////////////////////////////////
  ///////// Populates Tooltips Using Above Data ////////////
  //////////////////////////////////////////////////////////

  map.on('click', function(e) {
      var features = map.queryRenderedFeatures(e.point, {
          layers: ['listings']
      });

      if (!features.length) {
          return;
      }

      var feature = features[0];

      // Populate the popup and set its coordinates
      // based on the feature found.
      var popup = new mapboxgl.Popup()
          .setLngLat(feature.geometry.coordinates)
          .setHTML(feature.properties.description)
          .addTo(map);
  });


  // On every scroll event, check which element is on screen
  window.onscroll = function() {
      var listingNames = Object.keys(listings);
      for (var i = 0; i < listingNames.length; i++) {
          var listingName = listingNames[i];
          if (isElementOnScreen(listingName)) {
              setActiveListing(listingName);
              break;
          }
      }
  };

  var activeListingName = 'welcome';

  function setActiveListing(listingName) {
      if (listingName === activeListingName) return;

      map.flyTo(listings[listingName]);

      document.getElementById(listingName).setAttribute('class', 'active');
      document.getElementById(activeListingName).setAttribute('class', '');

      activeListingName = listingName;
  }

  function isElementOnScreen(id) {
      var element = document.getElementById(id);
      var bounds = element.getBoundingClientRect();
      return bounds.top < window.innerHeight && bounds.bottom > 0;
  }
}
