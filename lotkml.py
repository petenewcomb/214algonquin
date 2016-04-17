from geographiclib.geodesic import Geodesic
import math

equatorRadius = 6378.137 # equatorial radius in km
polarRadius = 6356.7523142 # polar radius in km

def degToRad(x):
    return x*math.pi/180

def radToDeg(x):
    return x*180/math.pi

def azimuthToRad(x):
    return degToRad(90-x)

def earthRadiusAtLatitude(lat):
#    return earthRadius
    return 1000 * ( equatorRadius*math.sqrt(math.pow(polarRadius,4)/math.pow(equatorRadius,4)*math.pow((math.sin(lat)),2)+math.pow(math.cos(lat),2))
             / math.sqrt(1-(1-(polarRadius*polarRadius)/( equatorRadius*equatorRadius))*math.pow(math.sin(lat),2)))

def ftToM(x):
    return x*12*2.54/100

def mToFt(x):
    return x*100/2.54/12

def azimuth(ns,d,m,s,ew):
    a = d + m/60.0 + s/3600.0
    if ns == 'S':
        a = 180 - a
    elif ns != 'N':
        raise ValueError, ns
    if ew == 'W':
        a = -a
    elif ew != 'E':
        raise ValueError, ew
#    a = a - 14.35 # magnetic declination in June 2009
    a = a - 13.00 # apparent magnetic declination
    while a < -180:
        a += 360
    while a > 180:
        a -= 360
    return a

#lon,lat = -73.94098416362,44.23961018733
lon,lat = -74.001604,44.289874
alt=ftToM(1961)
r=alt+earthRadiusAtLatitude(lat)

latcos=math.cos(degToRad(lat))

locs=[]
for a, d in [
        (azimuth('N',54,10,40,'E'),ftToM(263.00)),
        (azimuth('S',19,45,00,'E'),ftToM(177.00)),
        (azimuth('S',64,38,30,'W'),ftToM(237.46))
]:
    locs.append((lat,lon,alt))
    if 0:
        x = Geodesic.WGS84.Direct(lat,lon,a,d)
        lat = x['lat2']
        lon = x['lon2']
    else:
        arc=d/r
        latinc=radToDeg(math.sin(azimuthToRad(a))*arc)
        loninc=radToDeg(math.cos(azimuthToRad(a))*arc)/latcos
        lat=lat+latinc
        lon=lon+loninc
locs.append((lat,lon,alt))

print """\
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
	<Document>
		<name>214 Algonquin Drive</name>
		<Style id='propertyLines'>
			<LineStyle>
				<color>ff3644DB</color>
				<width>10</width>
			</LineStyle>
		</Style>
		<Placemark>
			<styleUrl>#propertyLines</styleUrl>
			<name>Property Lines</name>
			<MultiGeometry>
				<LineString>
					<tessellate>1</tessellate>
					<altitudeMode>clampToGround</altitudeMode>
					<coordinates>
""",

for lat, lon, alt in locs[:2]:
    print "						%.11f,%.11f,%d" % (lon,lat,0) #round(mToFt(alt)))
locs = locs[1:]

print """\
					</coordinates>
				</LineString>
				<LinearRing>
					<tessellate>1</tessellate>
					<altitudeMode>clampToGround</altitudeMode>
					<coordinates>
""",

for lat, lon, alt in locs[:5]:
    print "						%.11f,%.11f,%d" % (lon,lat,0) #round(mToFt(alt)))
locs = locs[4:]

print """\
					</coordinates>
				</LinearRing>
				<LinearRing>
					<tessellate>1</tessellate>
					<altitudeMode>clampToGround</altitudeMode>
					<coordinates>
""",

for lat, lon, alt in locs[:6]:
    print "						%.11f,%.11f,%d" % (lon,lat,0) #round(mToFt(alt)))
locs = locs[5:]

print """\
					</coordinates>
				</LinearRing>
			</MultiGeometry>
		</Placemark>
	</Document>
</kml>
""",
