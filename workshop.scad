use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <bedroom2_closet.scad>;

function workshop_x() = feet( 20);
function workshop_y() = feet( 15);
module position_workshop() {
    position_bedroom2_closet() {
        translate( [ 0, -exterior_wall_thickness() - workshop_y()]) {
            children();
        }
    }
}
module workshop() {
    position_workshop() {
        square( [ workshop_x(), workshop_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

workshop();
