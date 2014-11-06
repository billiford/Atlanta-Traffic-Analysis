<!DOCTYPE html>
<html>
<head>
	<!-- TODOs: move css stuff to style.css and javascript stuff to a 
		new javascript file. besides that, there's still a whole bunch
		of stuff like d3 and getting our ideas to work correctly.--> 
	<title>Atlanta Accident Analysis</title>
	
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	
	<script src="JavaScript/leaflet.js"></script>
	<script src="JavaScript/leaflet.markercluster-src.js"></script>
	<script src="JavaScript/papaparse.min.js"></script>
	<script src="JavaScript/jquery-2.1.1.js"></script>
	<script src="JavaScript/TileLayer.Grayscale.js"></script>

	<link rel="stylesheet" href="stylesheets/leaflet.css" />
	<link rel="stylesheet" href="stylesheets/MarkerCluster.css" />
	<link rel="stylesheet" href="stylesheets/MarkerCluster.Default.css" />
	
	<style type="text/css">
    	html, body {
    		height: 100%;
    		margin: 0;
    	}

    	#map {
    		min-height: 100%; 
			cursor: auto;
    	}
		
		#progress {
			display: none;
			position: absolute;
			z-index: 1000;
			left: 50%;
			top: 50%;
			width: 200px;
			height: 20px;
			margin-top: -20px;
			margin-left: -100px;
			background-color: #fff;
			background-color: rgba(255, 255, 255, 0.7);
			border-radius: 4px;
			padding: 2px;
		}
		
		#progress-bar {
			width: 0;
			height: 100%;
			background-color: #ffff66;
			border-radius: 4px;
		}
		
		#settings-pane {
			border: 2px solid #000000;
			border-radius: 10px;
			position: absolute;
			background-color: black;
			opacity: 0.6;
			width: 350px;
			height: 600px;
			top: 20px;
			left: 20px;
			z-index: 1001;
		}
		
		#d3-pane {
			border: 2px solid #000000;
			border-radius: 10px;
			position: absolute;
			background-color: black;
			opacity: 0.6;
			width: 400px;
			top: 20px;
			right: 20px;
			bottom: 20px;
			z-index: 1001;
		}
		
		#seasons {
			position: absolute;
			background-color: clear;
			width: 300px;
			height: 70px;
			top: 40px;
			left: 40px;
			z-index: 1002;
		}
		
		#SpringButton {
			opacity: .9;
			background: url("images/spring.png") no-repeat 0 0;
			background-size: 70px 70px;
			display: block;
			height: 70px;
			width: 70px;
			border-style:none;
			cursor: pointer;
			z-index: 10000;
		}
		
		#SummerButton {
			opacity: .9;
			background: url("images/summer.png") no-repeat 0 0;
			background-size: 70px 70px;
			display: block;
			margin-left: 80px;
			margin-top: -70px;
			height: 70px;
			width: 70px;
			border-style:none;
			cursor: pointer;
			z-index: 10000;
		}
		
		#FallButton {
			opacity: .9;
			background: url("images/fall.png") no-repeat 0 0;
			background-size: 70px 70px;
			display: block;
			margin-left: 160px;
			margin-top: -70px;
			height: 70px;
			width: 70px;
			border-style:none;
			cursor: pointer;
			z-index: 10000;
		}
		
		#WinterButton {
			opacity: .9;
			background: url("images/winter.png") no-repeat 0 0;
			background-size: 70px 70px;
			display: block;
			margin-left: 240px;
			margin-top: -70px;
			height: 70px;
			width: 70px;
			border-style:none;
			cursor: pointer;
			z-index: 10000;
		}

    </style>
</head>
<body>
	<div id="progress"><div id="progress-bar"></div></div>
	<div id="settings-pane"></div>
	<div id="d3-pane"></div>
	<div id="map"></div>
	<div id="seasons">
	    <form>
			<input type="button" id="SpringButton" class="season">
			<input type="button" id="SummerButton" class="season">
			<input type="button" id="FallButton" class="season">
			<input type="button" id="WinterButton" class="season">
		</form>
	</div>

	<script> 
	    var map = L.map('map', {zoomControl: false} ).setView([33.7488889, -84.3880556], 12);
		var progress = document.getElementById('progress');
		var progressBar = document.getElementById('progress-bar');
			
		L.tileLayer.grayscale('/CS4460-project/tiles/{z}/{x}/{y}.png', {
			maxZoom: 14,
			minZoom: 11,
			attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
				'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
				'Imagery © <a href="http://mapbox.com">Mapbox</a>',
			id: 'examples.map-i875mjb7'
		}).addTo(map);
		
		function updateProgressBar(processed, total, elapsed, layersArray) {
			if (elapsed > 1000) {
				// if it takes more than a second to load, display the progress bar:
				progress.style.display = 'block';
				progressBar.style.width = Math.round(processed/total*100) + '%';
			}
			if (processed === total) {
				// all markers processed - hide the progress bar:
				progress.style.display = 'none';
			}
		}
		
		function doStuff(data) {
			var markers = L.markerClusterGroup({ removeOutsideVisibleBounds: true, chunkinterval: 500, chunkdelay: 25, chunkedLoading: true, chunkProgress: updateProgressBar, showCoverageOnHover: false, zoomToBoundsOnClick: false, spiderfyOnMaxZoom: false });
			for (var i = 0; i < data.length; i++) {
				var marker = L.marker(new L.LatLng(data[i][0], data[i][1]));
				markers.addLayer(marker);
			}
			map.addLayer(markers);
		}
		
		function parseData(url, callBack) {
			Papa.parse(url, {
				download: true,
				worker: true,
				dynamicTyping: true,
				complete: function(results) {
					callBack(results.data);
				}
			});
		}
		
		parseData('/CS4460-project/csv/data_lat_long.csv', doStuff);


		/*L.polygon([
			[51.509, -0.08],
			[51.503, -0.06],
			[51.51, -0.047]
		]).addTo(map).bindPopup("I am a polygon.");*/


		var popup = L.popup();

		function onMapClick(e) {
			popup
				.setLatLng(e.latlng)
				.setContent("You clicked the map at " + e.latlng.toString())
				.openOn(map);
		}

		map.on('click', onMapClick);

	</script>
	
	<script>
		$(document).ready(function(){
			$('.season').click(
			function() {
				if ($(this).css("opacity") < 0.5) {
					$(this).fadeTo(1, 1);
				} else {
					$(this).fadeTo(1, .4);
				}
			});
			
			$('.season').hover(
			function() {
				if ($(this).css("opacity") > 0.6) {
					$(this).fadeTo(1, 1);
				} else {
					$(this).fadeTo(1, .4);
				}
			}, function() {
				if ($(this).css("opacity") < 0.5) {
					$(this).fadeTo(1, 0.3);
				} else {
					$(this).fadeTo(1, 0.9);
				}
			});
		})
	</script>
</body>
</html>
