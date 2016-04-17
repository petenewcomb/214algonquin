include <units.scad>;
include <math.scad>;

function azimuth_magnetic_correct( a) =
        a - 13.00; // apparent magnetic declination

function azimuth_apply_ns( ns, a) =
        ns == "S" ? 180 - a : a;

function azimuth_apply_ew( ew, a) =
        ew == "W" ? -a : a;

function azimuth_to_polar( ns, d, m, s, ew) =
        normalize_angle(
                90 - azimuth_magnetic_correct(
                        azimuth_apply_ew( ew,
                                          azimuth_apply_ns( ns,
                                                  d + m/60.0 + s/3600.0))));

function polygon_from_path( path) =
        concat( [ path[ 0]], polygon_from_path_internal( path, i = 1, s = path[ 0]));

function polygon_from_path_internal( path, i, s) =
        let( p = [ for ( j = [ 0: len( s) - 1]) s[ j] + path[ i][ j]],
             j = i + 1)
        j < len( path) ? concat( [ p], polygon_from_path_internal( path, i = j, s = p)) : [ p];


boundary_polar_path = [
        [ azimuth_to_polar( "N", 54, 10, 40, "E"), 263.00 * ft],
        [ azimuth_to_polar( "S", 19, 45, 00, "E"), 177.00 * ft],
        [ azimuth_to_polar( "S", 64, 38, 30, "W"), 237.46 * ft]
];

boundary_vector_path = concat( [ [ 0, 0]], [
        for ( p = boundary_polar_path)
            vector_from_polar( p[ 0], p[ 1])
]);

northwest_boundary_angle = boundary_polar_path[ 0][ 0];
northwest_boundary_length = boundary_polar_path[ 0][ 1];

northeast_boundary_angle = normalize_angle( 180 + boundary_polar_path[ 1][ 0]);
northeast_boundary_length = boundary_polar_path[ 1][ 1];

southeast_boundary_angle = normalize_angle( 180 + boundary_polar_path[ 2][ 0]);
southeast_boundary_length = boundary_polar_path[ 2][ 1];

boundary_corners = polygon_from_path( boundary_vector_path);

west_corner = boundary_corners[ 0];
north_corner = boundary_corners[ 1];
east_corner = boundary_corners[ 2];
south_corner = boundary_corners[ 3];

southwest_boundary_length = vector_length( vector_difference( south_corner, west_corner));
southwest_boundary_angle = let( v = vector_difference( south_corner, west_corner)) atan( v[ 1] / v[ 0]);

module lot_2d() {
    polygon( boundary_corners);
}
