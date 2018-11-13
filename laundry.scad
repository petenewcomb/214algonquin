use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <workshop.scad>;

function laundry_x() = feet( 8);
function laundry_y() = workshop_y();
module position_laundry() {
    position_workshop() {
        translate( [ workshop_x() + exterior_wall_thickness(), 0]) {
            children();
        }
    }
}
module laundry() {
    position_laundry() {
        square( [ laundry_x(), laundry_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

laundry();
