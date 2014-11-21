requirejs.config({
		baseUrl: 'JavaScript',
		paths: {
		leaflet: '../app'
	}
});

requirejs(['app/main']);