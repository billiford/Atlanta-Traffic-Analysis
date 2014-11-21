<!DOCTYPE html>
<html>
<head>
	<!-- TODOs: move css stuff to style.css and javascript stuff to a 
		new javascript file. besides that, there's still a whole bunch
		of stuff like d3 and getting our ideas to work correctly.--> 
	<title>Atlanta Accident Analysis</title>
	
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<script src="JavaScript/leaflet-src.js"></script>
	<script src="JavaScript/leaflet.markercluster-src.js"></script>
	<script src="JavaScript/papaparse.min.js"></script>
	<script src="JavaScript/jquery-2.1.1.js"></script>
	<script src="JavaScript/TileLayer.Grayscale.js"></script>
	<script src="http://d3js.org/d3.v3.min.js"></script>
	<script src="JavaScript/multithread.js"></script>

	<link rel="stylesheet" href="stylesheets/leaflet.css" />
	<link rel="stylesheet" href="stylesheets/MarkerCluster.css" />
	<link rel="stylesheet" href="stylesheets/MarkerCluster.Default.css" />
	<link rel="stylesheet" href="stylesheets/style.css" />

</head>
<body>
	<div id="progress"><div id="progress-bar"></div></div>
	<div id="settings-pane">
		<div id="seasons">
			<form>
				<input type="button" id="SpringButton" class="season">
				<input type="button" id="SummerButton" class="season">
				<input type="button" id="FallButton" class="season">
				<input type="button" id="WinterButton" class="season">
			</form>
		</div>
		<div id="timeOfDay">
			<form>
				<input type="button" id="DaytimeButton" class="season">
				<input type="button" id="NighttimeButton" class="season">
			</form>
		</div>
		<div id="checkboxes">
			<!-- <input type="checkbox" name="accidents" id="accidentsCheckbox" class="css-checkbox" />
			<label for="accidentsCheckbox" class="css-label">Option 1</label> -->
		</div>
	</div>
	<div id="d3-pane" class="d3-pane">
		<div id="accidentsByWeek" class="accidentsByWeek"></div>
		<div id="accidentsByZone" class="accidentsByZone"></div>
	</div>
	<div id="map"></div>

	<script> 

		var southWest = L.latLng(33.55064, -84.85318),
			northEast = L.latLng(34.1878, -84.00668),
			bounds = L.latLngBounds(southWest, northEast);
		
	    var map = L.map('map', {maxBounds: bounds} ).setView([33.7688889, -84.3680556], 12);
		var progress = document.getElementById('progress');
		var progressBar = document.getElementById('progress-bar');
		
		function tileLayer() {
			L.tileLayer('http://a.tile.stamen.com/toner/{z}/{x}/{y}.png', {
				maxZoom: 19,
				minZoom: 12,
				unloadInvisibleTiles: false,
				updateWhenIdle: true,
				attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
					'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
					'Imagery © <a href="http://mapbox.com">Mapbox</a>',
				id: 'examples.map-i875mjb7'
			}).addTo(map);
		}
		
		function createMarkers() {		
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
				var markers = L.markerClusterGroup({ spiderfyOnMaxZoom: false, 
													chunkinterval: 300, 
													chunkdelay: 25, 
													chunkedLoading: true, 
													chunkProgress: updateProgressBar, 
													showCoverageOnHover: false,
													disableClusteringAtZoom: 19, 
													maxClusterRadius: 100 });
				for (var i = 0; i < data.length; i++) {
					var marker = L.marker(new L.LatLng(data[i][0], data[i][1]));
					markers.addLayer(marker);
				}
				map.addLayer(markers);
			}

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
		}

		tileLayer();
		setTimeout(createMarkers, 900); 

	</script>
	
	<script>
		$(document).ready(function(){
			$('.season').click(
			function() {
				if ($(this).css("opacity") < 0.5) { $(this).fadeTo(1, 1);
				} else { $(this).fadeTo(1, .4); } });
			
			$('.season').hover(
			function() {
				if ($(this).css("opacity") > 0.6) { $(this).fadeTo(1, 1);
				} else { $(this).fadeTo(1, .4); }
			}, function() {
				if ($(this).css("opacity") < 0.5) { $(this).fadeTo(1, 0.3);
				} else { $(this).fadeTo(1, 0.9); } });
				
			$('.timeOfDay').click(
			function() {
				if ($(this).css("opacity") < 0.5) { $(this).fadeTo(1, 1);
				} else { $(this).fadeTo(1, .4); } });
			
			$('.timeOfDay').hover(
			function() {
				if ($(this).css("opacity") > 0.6) { $(this).fadeTo(1, 1);
				} else { $(this).fadeTo(1, .4); }
			}, function() {
				if ($(this).css("opacity") < 0.5) { $(this).fadeTo(1, 0.3);
				} else { $(this).fadeTo(1, 0.9); } });
		})
	</script>   


<script>

	// Set the dimensions of the canvas / graph
	var margin = {top: 30, right: 20, bottom: 30, left: 60},
		width = 400 - margin.left - margin.right,
		height = 270 - margin.top - margin.bottom;

	// Parse the date / time
	var parseDate = d3.time.format("%m/%d/%Y").parse; 

	// Set the ranges
	var weekX = d3.time.scale().range([0, width]);
	var weekY = d3.scale.linear().range([height, 0]);

	// Define the axes
	var weekXAxis = d3.svg.axis().scale(weekX)
		.orient("bottom").ticks(4);

	var weekYAxis = d3.svg.axis().scale(weekY)
		.orient("left").ticks(5);

	// Define the line
	var line = d3.svg.line()
		.x(function(d) { return weekX(d.date); })
		.y(function(d) { return weekY(d.total); });
		
	// Adds the svg canvas
	var svg2 = d3.select("#accidentsByWeek")
		.append("svg")
			.attr("width", width + margin.left + margin.right)
			.attr("height", height + margin.top + margin.bottom)
		.append("g")
			.attr("transform", 
				  "translate(" + margin.left + "," + margin.top + ")");

	// Get the data
	d3.csv("/Atlanta-Accident-Analysis/csv/accident_totals_by_week.csv", function(error, data) {
		data.forEach(function(d) {
			d.date = parseDate(d.date);
			d.total = +d.total;
	});

	// Scale the range of the data
	weekX.domain(d3.extent(data, function(d) { return d.date; }));
	weekY.domain([350, d3.max(data, function(d) { return d.total; })]); 

	// Add the X Axis
	svg2.append("g")
		.attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")")
		.call(weekXAxis)
		.append("text")
		.attr("dy", "2.11em")
		.attr("dx", "11.0em")
		.style("text-anchor", "end")
		.text("Month");

	// Add the Y Axis
	svg2.append("g")
		.attr("class", "y axis")
		.call(weekYAxis)
		.append("text")
		.attr("transform", "rotate(-90)")
		.attr("y", -55)
		.attr("dy", ".81em")
		.attr("dx", "-4.5em")
		.style("text-anchor", "end")
		.text("Accidents");

	
	svg2.append("path")
      .datum(data)
      .attr("class", "line")
      .attr("d", line);

});

</script>

<script>

	var margin = {top: 20, right: 20, bottom: 70, left: 50},
		width = 400 - margin.left - margin.right,
		height = 300 - margin.top - margin.bottom;

	var x = d3.scale.ordinal().rangeRoundBands([0, width], .1);

	var y = d3.scale.linear().range([height, 0]);

	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom")
		.ticks(6);

	var yAxis = d3.svg.axis()
		.scale(y)
		.orient("left")
		.ticks(5);

	var svg = d3.select("#accidentsByZone").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
	  .append("g")
		.attr("transform", 
			  "translate(" + margin.left + "," + margin.top + ")");

	d3.csv("/Atlanta-Accident-Analysis/csv/accident_totals_by_zone.csv", function(error, data) {

		data.forEach(function(d) {
			d.zone = +d.zone;
			d.total = +d.total;
		});
	 
	  x.domain(data.map(function(d) { return d.zone; }));
	  y.domain([0, d3.max(data, function(d) { return d.total; })]);

	  svg.append("g")
		  .attr("class", "x axis")
		  .attr("transform", "translate(0," + height + ")")
		  .call(xAxis)
		.selectAll("text")
		  .style("text-anchor", "end")
		  .attr("dx", ".4em");

	  svg.append("g")
		  .attr("class", "y axis")
		  .call(yAxis)
		.append("text")
		  .attr("y", 6)
		  .attr("dy", ".71em")
		  .style("text-anchor", "end");

	  svg.selectAll("bar")
		  .data(data)
		.enter().append("rect")
		  .style("fill", "steelblue")
		  .attr("x", function(d) { return x(d.zone); })
		  .attr("width", x.rangeBand())
		  .attr("y", function(d) { return y(d.total); })
		  .attr("height", function(d) { return height - y(d.total); });

	});

</script>

</body>
</html>
