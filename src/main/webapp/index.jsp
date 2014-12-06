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
	<script src="JavaScript/leaflet-invert.js"></script>
	<script src="http://d3js.org/d3.v3.min.js"></script>
	<script src="JavaScript/multithread.js"></script>
	<script src='https://api.tiles.mapbox.com/mapbox.js/plugins/leaflet-omnivore/v0.2.0/leaflet-omnivore.min.js'></script>

	<link rel="stylesheet" href="stylesheets/leaflet.css" />
	<link rel="stylesheet" href="stylesheets/MarkerCluster.css" />
	<link rel="stylesheet" href="stylesheets/MarkerCluster.Default.css" />
	<link rel="stylesheet" href="stylesheets/style.css" />
	<link rel="shortcut icon" href="/Atlanta-Accident-Analysis/images/shortcutIcon.ico">

</head>
<body>
	<div id="loading" class="loading"></div>
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
				<input type="button" id="NighttimeButton" class="season">
				<input type="button" id="DaytimeButton" class="season">
			</form>
		</div>
		<div id="reloadButton">
			<form>
				<input type="button" id="ReloadButton" class="reloadButton">
			</form>
		</div>
	</div>
	<div id="d3-pane" class="d3-pane">
		<div id="accidentsByWeek" class="accidentsByWeek"></div>
		<div id="accidentsByZone" class="accidentsByZone"></div>
	</div>
	<div id="d3-toggle-btn" class="d3-toggle-btn">
		<img src="/Atlanta-Accident-Analysis/images/d3-toggle-btn.gif" id="toggle-btn-img">
	</div>
	<div id="settings-pane-toggle-btn" class="settings-pane-toggle-btn">
		<img src="/Atlanta-Accident-Analysis/images/settings-pane-toggle-btn.gif" id="toggle-btn-img">
	</div>
	<div id="map"></div>

	<script> 
		var southWest = L.latLng(33.55064, -84.85318),
			northEast = L.latLng(34.1878, -84.00668),
			bounds = L.latLngBounds(southWest, northEast);
		
	    var map = L.map('map', {maxBounds: bounds} ).setView([33.7688889, -84.3680556], 11);
		var loading = document.getElementById('loading');
		
		function tileLayer() {
			L.tileLayer.invert('http://a.tile.stamen.com/toner/{z}/{x}/{y}.png', {
				maxZoom: 20,
				minZoom: 11,
				unloadInvisibleTiles: true,
				updateWhenIdle: false,
				attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
					'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
					'Imagery © <a href="http://mapbox.com">Mapbox</a>',
				id: 'examples.map-i875mjb7'
			}).addTo(map);
		}
		
		function createMarkers(spring, summer, fall, winter, day, night, totalToProcess) {		
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

			parseData('/Atlanta-Accident-Analysis/csv/data.csv', doStuff);

			var colors = {
				'pink': '#E1499A',
				'yellow': '#f0f000',
				'green': '#47e495'
			};

			var color2 = colors.yellow;

			var radius = 100;
			var border = 5;
			var padding = 30;
			var startPercent = 0;
			var endPercent = 0.0;

			var twoPi = Math.PI * 2;
			var formatPercent = d3.format('.0%');
			var boxSize = (radius + padding) * 2;

			var arc = d3.svg.arc()
				.startAngle(0)
				.innerRadius(radius)
				.outerRadius(radius - border);

			var parent = d3.select('#loading');

			var svg3 = parent.append('svg')
				.attr('width', boxSize)
				.attr('height', boxSize);

			var defs = svg3.append('defs');

			var filter = defs.append('filter')
				.attr('id', 'blur');

			filter.append('feGaussianBlur')
				.attr('in', 'SourceGraphic')
				.attr('stdDeviation', '7');

			var g3 = svg3.append('g')
				.attr('transform', 'translate(' + boxSize / 2 + ',' + boxSize / 2 + ')');

			var meter = g3.append('g')
				.attr('class', 'progress-meter');

			meter.append('path')
				.attr('class', 'background')
				.attr('fill', '#ccc')
				.attr('fill-opacity', 0.5)
				.attr('d', arc.endAngle(twoPi));

			var foreground = meter.append('path')
				.attr('class', 'foreground')
				.attr('fill', color2)
				.attr('fill-opacity', 1)
				.attr('stroke', color2)
				.attr('stroke-width', 3)
				.attr('stroke-opacity', 1);

			var front = meter.append('path')
				.attr('class', 'foreground')
				.attr('fill', color2)
				.attr('fill-opacity', 1);

			var numberText = meter.append('text')
				.attr('fill', '#fff')
				.attr('text-anchor', 'middle')
				.attr('font-size', '20px')
				.attr('dy', '.35em');

			function removeAppendLoadingCircle() {
				$('#loading').remove();
				$('body').append($('<div id="loading"></div>'));
				$("#loading").fadeOut();
			}
			
			function updateProgressBar(processed, total, elapsed, layersArray) {
				if (processed < total && elapsed > 100) {
					$("#loading").fadeIn();
					foreground.attr('d', arc.endAngle(twoPi * processed / totalToProcess));
					front.attr('d', arc.endAngle(twoPi * processed / totalToProcess));
					numberText.text(formatPercent(processed / totalToProcess));
				}
				if (processed === total) {
					foreground.attr('d', arc.endAngle(twoPi * processed / totalToProcess));
					front.attr('d', arc.endAngle(twoPi * processed / totalToProcess));
					numberText.text(formatPercent(processed / totalToProcess));
					$("#loading").fadeOut();
					setTimeout(removeAppendLoadingCircle, 500)
				}
			}

			function doStuff(data) {
				var markers = L.markerClusterGroup({ spiderfyOnMaxZoom: false, 
													chunkinterval: 300, 
													chunkdelay: 25, 
													chunkedLoading: true, 
													chunkProgress: updateProgressBar, 
													showCoverageOnHover: true,
													polygonOptions: { color: 'white' },
													disableClusteringAtZoom: 20, 
													maxClusterRadius: 150 });
				
				for (var i = 0; i < data.length; i++) {
					var date = Date.parse(data[i][0]);
					var time = Date.parse(data[i][0] + " " + data[i][8]);
					if (summer && date > Date.parse('6/20/2013') && date < Date.parse('9/22/2013')) {
						if (day && time > Date.parse(data[i][0] + " 6:00:00 AM") && time < Date.parse(data[i][0] + " 6:00:00 PM")) { addMarker(data, i);}
						else if (night && (time < Date.parse(data[i][0] + " 6:00:01 AM") || time > Date.parse(data[i][0] + " 5:59:59 PM"))) { addMarker(data, i); }
					} else if (spring && date > Date.parse('3/19/2013') && date < Date.parse('6/21/2013')) {
						if (day && time > Date.parse(data[i][0] + " 6:00:00 AM") && time < Date.parse(data[i][0] + " 6:00:00 PM")) { addMarker(data, i); }
						else if (night && (time < Date.parse(data[i][0] + " 6:00:01 AM") || time > Date.parse(data[i][0] + " 5:59:59 PM"))) { addMarker(data, i); }
					} else if (fall && date > Date.parse('9/21/2013') && date < Date.parse('12/21/2013')) {
						if (day && time > Date.parse(data[i][0] + " 6:00:00 AM") && time < Date.parse(data[i][0] + " 6:00:00 PM")) { addMarker(data, i); }
						else if (night && (time < Date.parse(data[i][0] + " 6:00:01 AM") || time > Date.parse(data[i][0] + " 5:59:59 PM"))) { addMarker(data, i); }
					} else if (winter && (date > Date.parse('12/20/2013') || date < Date.parse('3/20/2013'))) {
						if (day && time > Date.parse(data[i][0] + " 6:00:00 AM") && time < Date.parse(data[i][0] + " 6:00:00 PM")) { addMarker(data, i);} 
						else if (night && (time < Date.parse(data[i][0] + " 6:00:01 AM") || time > Date.parse(data[i][0] + " 5:59:59 PM"))) { addMarker(data, i); }
					} 
				}

				map.addLayer(markers);
				
				document.getElementById("reloadButton").onclick = function() { removeMarkers() };
				
				function addMarker(data, i) {
					var title = "Date: " + data[i][0] + "<br>" + "Time: " + data[i][8];
					var marker = L.marker(new L.LatLng(data[i][2], data[i][3]), { title: title } );
					marker.bindPopup(title);
					markers.addLayer(marker);
				}
				
				function removeMarkers() {
					map.removeLayer(markers);
				}
			}

			var popup = L.popup();

			function onMapClick(e) {
				popup
					.setLatLng(e.latlng)
					.setContent("You clicked the map at " + e.latlng.toString())
					.openOn(map);
			}

			map.on('click', onMapClick);
		}
		
		function showGrid() {
			var hoverStyle = {
				color: 'gray',
				fillColor: 'gray',
				fillOpacity: 0.3,
				opacity: 0.4,
				weight: 2
			};
			
			var notHoverStyle = {
				opacity: 0.0,
				fillOpacity: 0.0
			};
		
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

			var files = {1:"grid1.csv", 2:"grid2.csv", 3:"grid7.csv", 4:"grid8.csv"};
			var x;
			
			for (x in files) {
				parseData('/Atlanta-Accident-Analysis/csv/grid/' + files[x], doStuff);
			}
			
			function doStuff(data) {
				var rectangle = L.rectangle(data).addTo(map);
				
				rectangle.addEventListener('click', onPolygonClick);
				rectangle.setStyle(notHoverStyle);
				rectangle.addEventListener("mouseover", function(e) {
					rectangle.setStyle(hoverStyle);
					
				});
				
				rectangle.addEventListener("mouseout", function(e) {
					rectangle.setStyle(notHoverStyle);
				});
				
				function onMouseLeave() {
					this.style.display = 'none';
				}
				
				
				function onPolygonClick() {
					map.fitBounds(data);
				}
			}
		}
		
		showGrid();
		tileLayer();
		createMarkers(true, true, true, true, true, true, 32264); 

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
		$(document).ready(function() {
			$('.reloadButton').click(
			function() {
				var totalToProcess = 0;
				var spring, summer, fall, winter, day, night = false;
				if ($('#SpringButton').css("opacity") > .8) { spring = true; totalToProcess += 8371; } 
				if ($('#SummerButton').css("opacity") > .8) { summer = true; totalToProcess += 8490; } 
				if ($('#FallButton').css("opacity") > .8) { fall = true; totalToProcess += 8167; } 
				if ($('#WinterButton').css("opacity") > .8) { winter = true; totalToProcess += 7236; }
				if ($('#DaytimeButton').css("opacity") > .8) { day = true; }
				if ($('#NighttimeButton').css("opacity") > .8) {night = true; }
				createMarkers(spring, summer, fall, winter, day, night, totalToProcess);
			}
		)})
	</script>   
	
	<script>

		// Set the dimensions of the canvas / graph
		var margin = {top: 30, right: 20, bottom: 30, left: 80},
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
				.attr("height", height + margin.top + margin.bottom + 30)
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

		svg2.append("path")
			.datum(data)
			.attr("class", "line")
			.attr("fill", "none")
			.attr("stroke-width", 2)
			.style("stroke", "yellow")
			.style("opacity", 0.9)
			.attr("d", line);
		
		// Add the X Axis
		svg2.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + height + ")")
			.attr("shape-rendering", "auto")
			.style("opacity", 0.9)
			.call(weekXAxis)
			.attr("fill", "none")
			.style("stroke", "black")
			.attr("stroke-width", 1.5)
			.append("text")
			.attr("dy", "2.51em")
			.attr("dx", "11.2em")
			.style("text-anchor", "end")
			.text("Month");

		// Add the Y Axis
		svg2.append("g")
			.attr("class", "y axis")
			.call(weekYAxis)
			.attr("fill", "none")
			.style("stroke", "black")
			.attr("stroke-width", 1.5)
			.append("text")
			.attr("transform", "rotate(-90)")
			.attr("y", -55)
			.attr("dy", ".81em")
			.attr("dx", "-4.5em")
			.style("text-anchor", "end")
			.text("Accidents");

	});

	</script>

	<script>

		var margin = {top: 30, right: 20, bottom: 30, left: 80},
			width = 400 - margin.left - margin.right,
			height = 270 - margin.top - margin.bottom;

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
			.attr("height", height + margin.top + margin.bottom + 30)
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
		  
		  svg.selectAll("bar")
			  .data(data)
			.enter().append("rect")
			  .style("fill", "yellow")
			  .style("opacity", 0.7)
			  .attr("x", function(d) { return x(d.zone); })
			  .attr("width", x.rangeBand())
			  .attr("y", function(d) { return y(d.total); })
			  .attr("height", function(d) { return height - y(d.total); });

		  svg.append("g")
			  .attr("class", "x axis")
			  .attr("transform", "translate(0," + height + ")")
			  .call(xAxis)
			  .attr("fill", "none")
			  .style("stroke", "black")
			  .attr("stroke-width", 1.5)
			.selectAll("text")
			  .style("text-anchor", "end")
			  .attr("dx", ".4em");

		  svg.append("g")
			  .attr("class", "y axis")
			  .call(yAxis)
			  .attr("fill", "none")
			  .style("stroke", "black")
			  .attr("stroke-width", 1.5)
			.append("text")
			  .attr("transform", "rotate(-90)")
			  .attr("y", -55)
			  .attr("dy", "-.40em")
			  .attr("dx", "-4.5em")
			  .style("text-anchor", "end")
			  .text("Accidents");
		});

	</script>
	
	<script>
	$(function(){
		$('#d3-toggle-btn').click(function(){
			$('#d3-pane').stop().slideToggle(500);
			return false;
		});
	});
	</script>
	
	<script>
	$(function(){
		$('#settings-pane-toggle-btn').click(function(){
			$('#settings-pane').stop().slideToggle(500);
			return false;
		});
	});
	</script>

</body>
</html>
