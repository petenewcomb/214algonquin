
# exaggerate vertical
# (let ((x 597) (y 535)) (/ (sqrt (+ (* x x) (* y y))) 263))
# 3.0480781735351505


export GRASS_MESSAGE_FORMAT=plain

(
    set -x

    g.proj -c epsg=4326 location=latlong
    g.mapset mapset=PERMANENT location=latlong

    r.in.gdal -o -e input=fawnridge-plan-19871119-elevation.png output=contours location=xy
    g.mapset mapset=PERMANENT location=xy
    g.region rast=contours.red
)

x=0
while [ $x -lt 255 ]; do
    echo $x = $(($x/4+1906))
    x=$(($x+8))
done | (
    set -x
    r.reclass in=contours.red out=contours.elevations
)

(
    set -x

    r.thin in=contours.elevations out=contours.elevations.thinned
#    r.out.png input=contours.elevations.thinned output=thinned.png
    r.surf.contour input=contours.elevations.thinned output=elevation

    r.out.gdal in=elevation output=elevation.tif type=Float64 createopt="COMPRESS=DEFLATE"
)

