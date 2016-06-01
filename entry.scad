use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <powderroom.scad>;
use <laundry.scad>;
use <bedroom2_closet.scad>;
use <bedroom2_bath.scad>;
use <kitchen.scad>;
use <northwest_garage.scad>;
use <greatroom.scad>;

function entry_x() = bedroom2_closet_x() + interior_wall_thickness() + bedroom2_bath_x() + exterior_wall_thickness() + kitchen_x() + greatroom_x() - northwest_garage_x() - exterior_wall_thickness() - laundry_x() - exterior_wall_thickness();
function entry_y() = powderroom_y() + exterior_wall_thickness();
module position_entry() {
    position_powderroom() {
        translate( [ powderroom_x() + exterior_wall_thickness(), 0]) {
            children();
        }
    }
}
module entry() {
    position_entry() {
        square( [ entry_x(), entry_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

entry();
