// Create our App object.
window.App = window.App || {};

// Expose our code for Mapbox.
window.App.maps = window.App.maps || {};

window.App.maps.properties_map = require("./maps/properties_map");

// window.App.maps.clickable           = require("./maps/clickable");
// window.App.maps.data_binding        = require("./maps/data_binding");
// window.App.maps.directions          = require("./maps/directions");
// window.App.maps.flyby               = require("./maps/flyby");
// window.App.maps.geocoder            = require("./maps/geocoder");
// window.App.maps.languages           = require("./maps/languages");
// window.App.maps.navigation_controls = require("./maps/navigation_controls");
// window.App.maps.restriction_pane    = require("./maps/restriction_pane");

// Set Mapbox API key.
mapboxgl.accessToken = 'pk.eyJ1IjoicG1pbGxlcmsiLCJhIjoiY2lyM3VjMzNsMDFkZHR4bHdxOWs1amt1MiJ9.nc1fPKTYXlgC1zVoYS2Oag';
