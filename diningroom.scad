use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <kitchen.scad>;

function diningroom_x() = kitchen_x();
function diningroom_y() = feet( 12);
module position_diningroom() {
    position_kitchen() {
        translate( [ 0, kitchen_y()]) {
            children();
        }
    }
}
module diningroom() {
    position_diningroom() {
        square( [ diningroom_x(), diningroom_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

diningroom();
