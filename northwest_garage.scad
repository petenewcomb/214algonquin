use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <workshop.scad>;
use <bedroom2.scad>;
use <stairs.scad>;
use <diningroom.scad>;

function northwest_garage_x() = bedroom2_x() + interior_wall_thickness() + stairs_x() + diningroom_x();
function northwest_garage_y() = feet( 26);
module position_northwest_garage() {
    position_workshop() {
        translate( [ 0, -exterior_wall_thickness() - northwest_garage_y()]) {
            children();
        }
    }
}
module northwest_garage() {
    position_northwest_garage() {
        square( [ northwest_garage_x(), northwest_garage_y()]);
        echo( str( "northwest_garage: ", northwest_garage_x(), ", ", northwest_garage_y()));
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

northwest_garage();
