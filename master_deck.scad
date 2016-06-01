use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <master_bedroom.scad>;
use <main_deck.scad>;

function master_deck_x() = master_bedroom_x();
function master_deck_y() = main_deck_y() + feet( 4);
module position_master_deck() {
    position_main_deck() {
        translate( [ main_deck_x(), main_deck_y() - master_deck_y()]) {
            children();
        }
    }
}
module master_deck() {
    position_master_deck() {
        square( [ master_deck_x(), master_deck_y()]);
    }
}

// Standalone rendering
use <building_area.scad>;
%building_area_constraints();

master_deck();
