use <math.scad>;

function feet( x) = inches( x) * 12;
function inches( x) = x;

function loft_length() = feet(30.0);
function loft_width() = inches( 48.0);
function loft_surface_height() = inches( 98);
function loft_thickness() = inches( 6.0);

function loft_stairs_total_steps() = 13;
function loft_stairs_upper_flight_steps() = 6;

function loft_stairs_lower_flight_steps() = loft_stairs_total_steps() - loft_stairs_upper_flight_steps();
function loft_stairs_landing_body_width() = loft_stairs_tread_width() - loft_stairs_tread_run() / 2 - loft_stairs_tread_nose();
function loft_stairs_landing_surface_height() = loft_stairs_lower_flight_steps() * loft_stairs_tread_rise();


module loft() {
    union() {
        cut_in=inches(48-4)+loft_stairs_tread_run() / 2 + inches( 6.75) - loft_stairs_tread_run()/2;
        translate( [0, 0, loft_surface_height() - loft_thickness()]) {
            echo("stair cut-in",cut_in-inches(48));
            %cube([cut_in,inches(1),inches(1)]);
        }
        translate( [ inches( 48) - inches(4), -loft_width(), loft_surface_height() - loft_thickness()]) {
            difference() {
                cube( [ loft_length(), loft_width(), loft_thickness()]);
                #translate( [ -inches(1), loft_width() - loft_stairs_tread_width() - inches(6), -inches(1)]) {
                    cube( [ loft_stairs_tread_run() / 2 + inches( 6.75) + inches(1), loft_stairs_tread_width() + 2*inches(3) + inches(1), loft_thickness() + inches(2)]);
                }
            }
        }
        translate( [ inches(48), -loft_width() + inches(1.5), loft_surface_height() - inches(1)]) {
            cylinder(d=inches(.75),h=feet(7));
        }
        loft_stairs();
    }
}

module position_loft_stairs() {
//    position_greatroom() {
        translate( [ inches(3), inches(-3), 0]) {
            children();
        }
//    }
}

module loft_stairs() {
    position_loft_stairs() {
        union() {
            translate( [ 0, -( loft_stairs_tread_width() - loft_stairs_tread_nose() + ( loft_stairs_lower_flight_steps() - 2) * loft_stairs_tread_run() / 2), 0]) {
                for (i = [ 1: loft_stairs_lower_flight_steps()]) {
                    left = ( i % 2) == 0;
                    translate( [ left ? 0 : loft_stairs_tread_width(), i * loft_stairs_tread_run() / 2, i * loft_stairs_tread_rise()]) {
                        scale( [ left ? 1 : -1, 1, 1]) {
                            color( [ left ? 1.0 : 0.0, 0.5, left ? 0.0 : 1.0]) {
                                loft_stairs_tread();
                            }
                        }
                    }
                }
            }
            translate( [ 0, 0, loft_stairs_landing_surface_height()]) {
                translate( [ 0, -loft_stairs_landing_body_width() + inches(4.75), -loft_stairs_tread_thickness()]) {
                    cube( [ loft_stairs_tread_width(), loft_stairs_landing_body_width() - inches(4.75), loft_stairs_tread_thickness()]);
                }
                rotate( [ 0, 0, -90]) {
                    translate( [ 0, loft_stairs_tread_width(), 0]) {
                        for (i = [ 1: loft_stairs_upper_flight_steps()]) {
                            left = ( i % 2) != 0;
                            translate( [ left ? 0 : loft_stairs_tread_width(), i * loft_stairs_tread_run() / 2, i * loft_stairs_tread_rise()]) {
                                scale( [ left ? 1 : -1, 1, 1]) {
                                    color( [ left ? 1.0 : 0.0, 0.5, left ? 0.0 : 1.0]) {
                                        loft_stairs_tread();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            loft_stairs_lower_left_stringer();
            translate( [ loft_stairs_landing_body_width() + 2 * inches(3), 0, 0]) scale( [ -1, 1, 1]) loft_stairs_lower_left_stringer();
        }
    }
}


module loft_stairs_lower_left_stringer() {
    depth = inches(6);
    width = inches(3);
    thickness = inches( 5.0/16);
    bottom_length_x = loft_stairs_lower_flight_steps() * loft_stairs_tread_run() / 2;
    bottom_length_y = loft_stairs_landing_surface_height();
    angle = atan2( loft_stairs_tread_rise(), loft_stairs_tread_run() / 2);
    union() {
        translate( [ 0, loft_stairs_tread_run() / 2 - loft_stairs_landing_body_width(), loft_stairs_landing_surface_height() - loft_stairs_tread_thickness()]) {
            rotate( [ 0, 90 + angle, -90]) {
                translate( [ -depth, 0, ( depth - loft_stairs_tread_thickness()) / sin(angle) - depth * tan(angle/2)]) {
                    difference() {
                        length = vector_length( [ bottom_length_x, bottom_length_y]) - depth / sin(angle) + depth * tan(angle/2) + depth / tan(angle);
                        translate([0, -width, 0]) cube( [ depth, width, length]);
//                        c_channel( depth = depth, width = width, thickness = thickness, length = length);
                        rotate( [ 0, -angle/2, 0]) translate( [ -depth/2, -1.5 * width, -max(width,depth) * 2]) cube( [ depth * 2, width * 2, max(width,depth) * 2]);
                        translate( [ 0, 0, length]) rotate( [ 0, 90 - angle, 0]) translate( [ -depth/2, -1.5 * width, 0]) cube( [ depth * 2, width * 2, max(width,depth) * 2]);
                    }
                }
            }
        }
        translate( [ 0, width, loft_stairs_tread_rise() * loft_stairs_lower_flight_steps()]) {
            rotate( [ 0, 90, -90]) {
                difference() {
                    length = loft_stairs_landing_body_width() + width + cos(angle) * loft_stairs_tread_thickness();
                    translate([0, -width, 0]) cube( [ depth, width, length]);
//                    c_channel( depth = depth, width = width, thickness = thickness, length = length);
                    translate( [ 0, 0, length]) rotate( [ 0, angle/2, 0]) translate( [ -depth/2, -1.5 * width, 0]) cube( [ depth * 2, width * 2, max(width,depth) * 2]);
                }
            }
        }
    }
}


/*
 *
 * y1 - A-------------B
 *      |             |
 * y2 - |       D-----C
 *      |      /
 * y3 - F-----E
 *
 *      |     | |     |
 *
 *      x     x x     x
 *      1     2 3     4
 */

function loft_stairs_tread_rise() = loft_surface_height() / loft_stairs_total_steps();
function loft_stairs_tread_run() = inches( 9.5);

echo(rise=loft_stairs_tread_rise());

function loft_stairs_tread_thickness() = inches(2);
function loft_stairs_tread_width() = inches(24);
function loft_stairs_tread_nose() = inches(1);
function loft_stairs_tread_separation() = 0;

module loft_stairs_tread() {
    translate( [ 0, 0, -loft_stairs_tread_thickness()]) {
        linear_extrude( height = loft_stairs_tread_thickness()) {

            y1 = 0;
            y2 = y1 - loft_stairs_tread_run() / 2;
            y3 = y1 - loft_stairs_tread_run() - loft_stairs_tread_nose();

            x1 = 0;
            x2 = loft_stairs_tread_width() / 2 - loft_stairs_tread_separation() / 2;
            x3 = x2 + loft_stairs_tread_separation();
            x4 = loft_stairs_tread_width();

            A = [ x1, y1];
            B = [ x4, y1];
            C = [ x4, y2];
            D = [ x3, y2];
            E = [ x2, y3];
            F = [ x1, y3];

            polygon( points = [ A, B, C, D, E, F]);
        }
    }
}



/*
 *
 * y1 - A-----------B
 * y2 - | E-------D |
 *      |/         \|
 * y3 - F           C
 *
 *      | |       | |
 *
 *      x x       x x
 *      1 2       3 4
 */

module c_channel( depth, width, thickness, length) {
    linear_extrude( height = length) {
        y1 = 0;
        y2 = -thickness;
        y3 = -width;

        x1 = 0;
        x2 = 2 * thickness;
        x3 = depth - 2 * thickness;
        x4 = depth;

        A = [ x1, y1];
        B = [ x4, y1];
        C = [ x4, y3];
        D = [ x3, y2];
        E = [ x2, y2];
        F = [ x1, y3];

        polygon( points = [ A, B, C, D, E, F]);
    }
}



// Standalone rendering
loft();
