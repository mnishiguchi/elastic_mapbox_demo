// Create our App object.
window.App = window.App || {};

// Expose our code for Mapbox.
window.App.maps = window.App.maps || {};

window.App.maps.propertiesMap = require("./maps/properties_map");

// Set Mapbox API key.
window.mapboxgl.accessToken = 'pk.eyJ1IjoicG1pbGxlcmsiLCJhIjoiY2lyM3VjMzNsMDFkZHR4bHdxOWs1amt1MiJ9.nc1fPKTYXlgC1zVoYS2Oag';
