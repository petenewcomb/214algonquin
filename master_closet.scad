use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <master_bath.scad>;
use <master_bedroom_entry.scad>;

function master_closet_x() = feet( 9);
function master_closet_y() = master_bath_y();
module position_master_closet() {
    position_master_bedroom_entry() {
        translate( [ master_bedroom_entry_x() + exterior_wall_thickness(), 0]) {
            children();
        }
    }
}
module master_closet() {
    position_master_closet() {
        square( [ master_closet_x(), master_closet_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

master_closet();
