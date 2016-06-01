use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <master_bedroom_entry.scad>;
use <master_closet.scad>;
use <master_bath.scad>;

function southeast_garage_x() = master_bedroom_entry_x() + exterior_wall_thickness() + master_closet_x() + exterior_wall_thickness() + master_bath_x();
function southeast_garage_y() = feet( 24.5);
module position_southeast_garage() {
    position_master_bedroom_entry() {
        translate( [ 0, -exterior_wall_thickness() - southeast_garage_y()]) {
            children();
        }
    }
}
module southeast_garage() {
    position_southeast_garage() {
        square( [ southeast_garage_x(), southeast_garage_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

southeast_garage();
