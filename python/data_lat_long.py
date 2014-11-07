#################################################
#						#										
#	This class used to parse data.csv	#
#	and output just the latitude and	#
#	longitude comma separated values	#
#	in correct format without a header	#
#						#				
#################################################

import csv

lons = []
lats = []
countlons = 0
countlats = 0

with open('data.csv', 'rb') as csvfile:
    reader = csv.DictReader(csvfile, delimiter=',')
    for row in reader:
        if row["avg_long"] != "" and row["avg_long"] != "NULL":
            lons.append(row["avg_long"])
        if row["avg_lat"] != "" and row["avg_lat"] != "NULL":
            lats.append(row["avg_lat"])

for i in range(0, len(lons)):
    lons[i] = "-" + lons[i][0:2] + "." + lons[i][2:]
for i in range(0, len(lats)):
    lats[i] = lats[i][0:2] + "." + lats[i][2:]
lat_long = [[0 for x in xrange(len(lats))] for x in xrange(len(lons))]
for i in range(0, len(lons)):
    lat_long[i][0] = lats[i]
    lat_long[i][1] = lons[i]

for i in range(0, len(lons)):
    print lat_long[i][0]


with open('data_lat_long.csv', 'wb') as f:
    writer = csv.writer(f)
    for i in range(0, len(lat_long)):
        writer.writerow([lat_long[i]])
