use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <greatroom.scad>;

function master_bedroom_x() = feet( 18.5);
function master_bedroom_y() = feet( 13);
module position_master_bedroom() {
    position_greatroom() {
        translate( [ greatroom_x() + exterior_wall_thickness(), greatroom_y() - feet( 4) - master_bedroom_y()]) {
            children();
        }
    }
}
module master_bedroom() {
    position_master_bedroom() {
        square( [ master_bedroom_x(), master_bedroom_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

master_bedroom();
