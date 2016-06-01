use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <bedroom2_closet.scad>;

function northwest_garage_x() = feet( 30);
function northwest_garage_y() = feet( 30);
module position_northwest_garage() {
    position_bedroom2_closet() {
        translate( [ 0, -exterior_wall_thickness() - northwest_garage_y()]) {
            children();
        }
    }
}
module northwest_garage() {
    position_northwest_garage() {
        square( [ northwest_garage_x(), northwest_garage_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

northwest_garage();
