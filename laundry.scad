use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <mudroom.scad>;

function laundry_x() = feet( 12.5);
function laundry_y() = feet( 8.5);
module position_laundry() {
    position_mudroom() {
        translate( [ 0, -laundry_y()]) {
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
