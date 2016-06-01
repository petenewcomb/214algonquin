use <units.scad>;
use <math.scad>;
use <constants.scad>;

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


function boundary_polar_path() = [
        [ azimuth_to_polar( "N", 54, 10, 40, "E"), feet( 263.00)],
        [ azimuth_to_polar( "S", 19, 45, 00, "E"), feet( 177.00)],
        [ azimuth_to_polar( "S", 64, 38, 30, "W"), feet( 237.46)]
];

function boundary_vector_path() = concat( [ [ 0, 0]], [
        for ( p = boundary_polar_path())
            polar_to_vector( p[ 0], p[ 1])
]);

function northwest_boundary_angle() = boundary_polar_path()[ 0][ 0];
function northwest_boundary_length() = boundary_polar_path()[ 0][ 1];

function northeast_boundary_angle() = normalize_angle( 180 + boundary_polar_path()[ 1][ 0]);
function northeast_boundary_length() = boundary_polar_path()[ 1][ 1];

function southeast_boundary_angle() = normalize_angle( 180 + boundary_polar_path()[ 2][ 0]);
function southeast_boundary_length() = boundary_polar_path()[ 2][ 1];

function boundary_corners() = polygon_from_path( boundary_vector_path());

function west_corner() = boundary_corners()[ 0];
function north_corner() = boundary_corners()[ 1];
function east_corner() = boundary_corners()[ 2];
function south_corner() = boundary_corners()[ 3];

function southwest_boundary_length() = vector_length( vector_difference( south_corner(), west_corner()));
function southwest_boundary_angle() = let( v = vector_difference( south_corner(), west_corner())) atan( v[ 1] / v[ 0]);

module position_lot() {
    children();
}

module lot_2d() {
    position_lot() {
        polygon( boundary_corners());
    }
}

module lot_lines() {
    position_lot() {
        %difference() {
            offset( delta = interior_wall_thickness()) lot_2d();
            lot_2d();
        }
    }
}

/* Big rock next to driveway */
module position_rock() {
    position_lot() {
        rotate( [ 0, 0, -northwest_boundary_angle()]) {
            translate( [ feet( 48), feet( 50)]) {
                children();
            }
        }
    }
}
module rock() {
    position_rock() {
        %circle( r = feet( 5));
    }
}

/* Big tree next to driveway */
module position_bigtree() {
    position_lot() {
        rotate( [ 0, 0, -northwest_boundary_angle()]) {
            translate( [ feet( 69), feet( 40)]) {
                children();
            }
        }
    }
}
module bigtree() {
    position_bigtree() {
        %circle( r = feet( 5));
    }
}

/* Electrical meter */
module position_meter() {
    position_lot() {
        rotate( [ 0, 0, southwest_boundary_angle()]) {
            translate( [ southwest_boundary_length() - feet( 30), feet( 31)]) {
                children();
            }
        }
    }
}
module meter() {
    position_meter() {
        rotate( [ 0, 0, 45]) {
            %square( [ feet( 5), feet( 1)]);
        }
    }
}

module lot_constraints() {
    lot_lines();
    rock();
    bigtree();
    meter();
}

// Standalone rendering
%lot_constraints();
