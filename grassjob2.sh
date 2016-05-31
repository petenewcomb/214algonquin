
# exaggerate vertical
# (let ((x 597) (y 535)) (/ (sqrt (+ (* x x) (* y y))) 263))
# 3.0480781735351505

# 1013x1018 pixels starting at offset 1880,3350


export GRASS_MESSAGE_FORMAT=plain

(
    set -x

    g.proj -c epsg=4326 location=latlong
    g.mapset mapset=PERMANENT location=latlong

    r.in.gdal -o -e input=elevation2.tif output=elevation location=xy
    g.mapset mapset=PERMANENT location=xy
    g.region rast=elevation

    r.slope.aspect elevation=elevation slope=slope format=percent zfactor=3.04

    r.out.gdal in=slope output=slope2.tif type=Float64 createopt="COMPRESS=DEFLATE"
)

