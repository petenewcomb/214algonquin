use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <northwest_garage.scad>;

function mudroom_x() = feet( 8);
function mudroom_y() = feet( 8);
module position_mudroom() {
    position_northwest_garage() {
        translate( [ northwest_garage_x() + exterior_wall_thickness(), northwest_garage_y() - mudroom_y()]) {
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
