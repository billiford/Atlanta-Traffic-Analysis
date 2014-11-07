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
	<link rel="stylesheet" href="stylesheets/style.css" />
	<style> /* set the CSS */

		body { font: 12px Arial; }

		path { 
			stroke: steelblue;
			stroke-width: 2;
			fill: none;
		}

		.axis path,
		.axis line {
			fill: none;
			stroke: yellow;
			stroke-width: 2;
			shape-rendering: crispEdges;
		}
		
		.axis text {
			fill: yellow;
		}

	</style>

</head>
<body>
	<div id="progress"><div id="progress-bar"></div></div>
	<div id="settings-pane">
		<input type="checkbox" name="accidents" id="accidents" class="css-checkbox" />
		<label for="accidents" class="css-label">Option 1</label>
	</div>
	<div id="d3-pane" class="d3-pane"></div>
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
		var southWest = L.latLng(33.55064, -84.85318),
			northEast = L.latLng(34.1878, -84.00668),
			bounds = L.latLngBounds(southWest, northEast);
		
	    var map = L.map('map', {zoomControl: false, maxBounds: bounds} ).setView([33.7488889, -84.3880556], 12);
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
		
		parseData('/Atlanta-Accident-Analysis/csv/data_lat_long.csv', doStuff);


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


<!-- load the d3.js library -->    
<script src="http://d3js.org/d3.v3.min.js"></script>

<script>

	// Set the dimensions of the canvas / graph
	var margin = {top: 30, right: 20, bottom: 30, left: 50},
		width = 400 - margin.left - margin.right,
		height = 270 - margin.top - margin.bottom;

	// Parse the date / time
	var parseDate = d3.time.format("%m/%d/%Y").parse; 

	// Set the ranges
	var x = d3.time.scale().range([0, width]);
	var y = d3.scale.linear().range([height, 0]);

	// Define the axes
	var xAxis = d3.svg.axis().scale(x)
		.orient("bottom").ticks(4);

	var yAxis = d3.svg.axis().scale(y)
		.orient("left").ticks(5);

	// Define the line
	var priceline = d3.svg.line()
		.x(function(d) { return x(d.date); })
		.y(function(d) { return y(d.total); });
		
	// Adds the svg canvas
	var svg = d3.select(".d3-pane")
		.append("svg")
			.attr("width", width + margin.left + margin.right)
			.attr("height", height + margin.top + margin.bottom)
		.append("g")
			.attr("transform", 
				  "translate(" + margin.left + "," + margin.top + ")");

	// Get the data
		d3.csv("/Atlanta-Accident-Analysis/csv/accident_totals.csv", function(error, data) {
			data.forEach(function(d) {
			    d.date = parseDate(d.date);
			    d.total = +d.total;
		});

		// Scale the range of the data
		x.domain(d3.extent(data, function(d) { return d.date; }));
		y.domain([0, d3.max(data, function(d) { return d.total; })]); 

		// Nest the entries by symbol
		var dataNest = d3.nest()
			.key(function(d) {return d.season;})
			.entries(data);
			
		/*var text = svg.selectAll("text")
                          .data(priceline)
                          .enter()
                          .append("text");
	
		var textLabels = text
                   .attr("font-family", "sans-serif")
                   .attr("font-size", "20px")
                   .attr("fill", "red");*/

		// Loop through each symbol / key
		dataNest.forEach(function(d) {
			svg.append("path")
				.attr("class", "line")
				.attr("d", priceline(d.values)); 

		});

		// Add the X Axis
		svg.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + height + ")")
			.call(xAxis);

		// Add the Y Axis
		svg.append("g")
			.attr("class", "y axis")
			.call(yAxis);

	});

</script>
</body>
</html>
