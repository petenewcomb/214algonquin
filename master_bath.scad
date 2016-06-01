use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <master_closet.scad>;

function master_bath_x() = feet( 13);
function master_bath_y() = feet( 6);
module position_master_bath() {
    position_master_closet() {
        translate( [ master_closet_x() + exterior_wall_thickness(), 0]) {
            children();
        }
    }
}
module master_bath() {
    position_master_bath() {
        square( [ master_bath_x(), master_bath_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

master_bath();
