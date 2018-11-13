use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <lot.scad>;
use <building_area.scad>;

use <greatroom.scad>;
use <diningroom.scad>;
use <bedroom2.scad>;
use <stairs.scad>;

//function house_orientation_angle() = vector_to_angle( vector_difference( building_area_northeast_corner(), building_area_north_corner()));
function house_orientation_angle() = vector_to_angle( vector_difference( building_area_south_corner(), building_area_west_corner()));

function main_deck_x() = bedroom2_x() + interior_wall_thickness() + stairs_x() + diningroom_x() + greatroom_x() + exterior_wall_thickness();
function main_deck_y() = feet( 9);
module position_main_deck() {
    position_lot() {
        translate( building_area_northeast_corner()) {
            rotate( [ 0, 0, house_orientation_angle()]) {
                translate( [ -main_deck_x() + feet( 0), -main_deck_y() - feet( 0)]) {
                    children();
                }
            }
        }
    }
}
module main_deck() {
    position_main_deck() {
        square( [ main_deck_x(), main_deck_y()]);
    }
}

// Standalone rendering
%building_area_constraints();

main_deck();
