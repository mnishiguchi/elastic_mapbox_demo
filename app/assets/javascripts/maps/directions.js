module.exports = function() {

  console.log('hello from directions');

  const map = mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/light-v9',
      center: [-77.356746, 38.957575],
      zoom: 12
  });

  map.addControl(new mapboxgl.Directions());
}
