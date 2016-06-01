use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <stairs.scad>;

function bedroom2_x() = feet( 15);
function bedroom2_y() = feet( 15);
module position_bedroom2() {
    position_stairs() {
        translate( [ -interior_wall_thickness() - bedroom2_x(), 0]) {
            children();
        }
    }
}
module bedroom2() {
    position_bedroom2() {
        square( [ bedroom2_x(), bedroom2_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

bedroom2();
