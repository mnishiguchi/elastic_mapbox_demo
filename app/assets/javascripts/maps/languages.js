module.exports = function() {

  console.log('hello from languages');

  var map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/light-v9',
      center: [16.05, 48],
      zoom: 2.9
  });

  document.getElementById('buttons').addEventListener('click', function(event) {
      var language = event.target.id.substr('button-'.length);
      // Use setLayoutProperty to set the value of a layout property in a style layer.
      // The three arguments are the id of the layer, the name of the layout property,
      // and the new property value.
      map.setLayoutProperty('country-label-lg', 'text-field', '{name_' + language + '}');
  });
}
