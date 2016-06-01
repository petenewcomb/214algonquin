use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <master_bedroom.scad>;
use <master_closet.scad>;

function master_bedroom_entry_x() = feet( 4);
function master_bedroom_entry_y() = master_closet_y() + exterior_wall_thickness();
module position_master_bedroom_entry() {
    position_master_bedroom() {
        translate( [ 0, -master_bedroom_entry_y()]) {
            children();
        }
    }
}
module master_bedroom_entry() {
    position_master_bedroom_entry() {
        square( [ master_bedroom_entry_x(), master_bedroom_entry_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

master_bedroom_entry();
