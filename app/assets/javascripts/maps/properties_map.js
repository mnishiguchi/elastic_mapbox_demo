module.exports = function() {

  console.log('hello from geocoder');

  const map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/streets-v9',
      center: [-77.356746, 38.957575],
      zoom: 13
  });
}
