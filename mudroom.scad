use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <greatroom.scad>;

function mudroom_x() = greatroom_x();
function mudroom_y() = feet( 8);
module position_mudroom() {
    position_greatroom() {
        translate( [ exterior_wall_thickness(), -exterior_wall_thickness() - mudroom_y()]) {
            children();
        }
    }
}
module mudroom() {
    position_mudroom() {
        square( [ mudroom_x(), mudroom_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

mudroom();
