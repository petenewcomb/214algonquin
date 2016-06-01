use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <bedroom2.scad>;
use <diningroom.scad>;

function stairs_x() = feet( 8) + exterior_wall_thickness();
function stairs_y() = bedroom2_y();
module position_stairs() {
    position_diningroom() {
        translate( [ -stairs_x(), diningroom_y() - stairs_y()]) {
            children();
        }
    }
}
module stairs() {
    position_stairs() {
        square( [ stairs_x(), stairs_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

stairs();
