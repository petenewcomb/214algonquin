use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <mudroom.scad>;
use <laundry.scad>;

function powderroom_x() = laundry_x() - mudroom_x() - exterior_wall_thickness();
function powderroom_y() = mudroom_y() - exterior_wall_thickness();
module position_powderroom() {
    position_mudroom() {
        translate( [ mudroom_x() + exterior_wall_thickness(), exterior_wall_thickness()]) {
            children();
        }
    }
}
module powderroom() {
    position_powderroom() {
        square( [ powderroom_x(), powderroom_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

powderroom();
