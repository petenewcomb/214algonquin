use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <diningroom.scad>;
use <greatroom.scad>;

function kitchen_x() = feet( 15.5);
function kitchen_y() = greatroom_y() - diningroom_y();
module position_kitchen() {
    position_greatroom() {
        translate( [ -kitchen_x(), 0]) {
            children();
        }
    }
}
module kitchen() {
    position_kitchen() {
        square( [ kitchen_x(), kitchen_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

bedroom2();
