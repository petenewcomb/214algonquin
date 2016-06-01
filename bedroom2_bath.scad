use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <stairs.scad>;
use <kitchen.scad>;
use <diningroom.scad>;

function bedroom2_bath_x() = feet( 8);
function bedroom2_bath_y() = kitchen_y() + diningroom_y() - stairs_y() - exterior_wall_thickness();
module position_bedroom2_bath() {
    position_stairs() {
        translate( [ stairs_x() - exterior_wall_thickness() - bedroom2_bath_x(), -exterior_wall_thickness() - bedroom2_bath_y()]) {
            children();
        }
    }
}
module bedroom2_bath() {
    position_bedroom2_bath() {
        square( [ bedroom2_bath_x(), bedroom2_bath_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

bedroom2_bath();
