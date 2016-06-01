use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <bedroom2_bath.scad>;

function bedroom2_closet_x() = feet( 7);
function bedroom2_closet_y() = bedroom2_bath_y();
module position_bedroom2_closet() {
    position_bedroom2_bath() {
        translate( [ -interior_wall_thickness() - bedroom2_closet_x(), 0]) {
            children();
        }
    }
}
module bedroom2_closet() {
    position_bedroom2_closet() {
        square( [ bedroom2_closet_x(), bedroom2_closet_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

bedroom2_closet();
