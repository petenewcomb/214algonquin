use <math.scad>;
use <units.scad>;
use <constants.scad>;

use <main_deck.scad>;
use <greatroom.scad>;
use <stairs.scad>;
use <bedroom2.scad>;
use <bedroom2_bath.scad>;
use <bedroom2_closet.scad>;
use <diningroom.scad>;
use <kitchen.scad>;
use <northwest_garage.scad>;
use <mudroom.scad>;
use <laundry.scad>;
use <powderroom.scad>;
use <entry.scad>;
use <master_bedroom.scad>;
use <master_bedroom_entry.scad>;
use <master_bath.scad>;
use <master_closet.scad>;
use <southeast_garage.scad>;
use <master_deck.scad>;
use <workshop.scad>;

module upperfloor_rooms() {
    main_deck();
    greatroom();
    kitchen();
    diningroom();
    stairs();
    bedroom2();
    bedroom2_bath();
    bedroom2_closet();
    northwest_garage();
    mudroom();
    laundry();
    entry();
    powderroom();
    master_bedroom();
    master_bedroom_entry();
    master_bath();
    master_closet();
    southeast_garage();
    master_deck();
    workshop();
/*
    garage();
    workshop();
    mudroom();
    northwest_hallway();
    bedroom2();
    bedroom2_closet();
    bathroom2();
    master_closet();
    entrance_hall();
    powder_room();
    master_bedroom();
    master_bathroom();
*/
}

module upperfloor_walls_2d() {
    difference() {
        internal_offset_thickness = max( interior_wall_thickness(), exterior_wall_thickness()) + inches( 1);
        offset( delta = exterior_wall_thickness() - internal_offset_thickness) {
            offset( delta = internal_offset_thickness) {
                upperfloor_rooms();
            }
        }
        upperfloor_rooms();
    }
}

module door_cutouts() {
/*
    garage_door_cutouts();
    workshop_door_cutouts();
    mudroom_door_cutouts();
    greatroom_cutouts();
    main_entrance_cutouts();
    powder_room_cutouts();
    master_bedroom_cutouts();
*/
}

module floorplan() {
    difference() {
        upperfloor_walls_2d();
        union() {
            door_cutouts();
            translate( [ 0, 0, -1]) {
                door_cutouts();
            }
        }
    }
}

// Standalone rendering
use <lot.scad>;
use <building_area.scad>;
rotate( [ 0, 0, -house_orientation_angle()]) {
    translate( vector_difference( [ 0, 0], building_area_west_corner())) {
        %building_area_constraints();
//        floorplan();
        upperfloor_rooms();
    }
}
