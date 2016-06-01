use <math.scad>;
use <units.scad>;
use <constants.scad>;
use <lot.scad>;
use <building_area.scad>;
use <main_deck.scad>;

function greatroom_x() = feet( 21.5);
function greatroom_y() = feet( 26);
module position_greatroom() {
    position_main_deck() {
        translate( [ main_deck_x() - greatroom_x() - exterior_wall_thickness(), -exterior_wall_thickness() - greatroom_y()]) {
            children();
        }
    }
}
module greatroom() {
    position_greatroom() {
        square( [ greatroom_x(), greatroom_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

greatroom();
