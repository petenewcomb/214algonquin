include <shed_roof.scad>;
include <units.scad>;
include <lot.scad>;
include <building_area.scad>;
include <MCAD/2Dshapes.scad>;

basement_depth = 10 * ft;
roof_height_max = 30 * ft - basement_depth;

roof_rvalue_min = 49;
exterior_wall_rvalue_min = 21;
rvalue_per_in_closed_cell_foam = 6.5;
rvalue_per_in_fiberglass = 3;

roof_thickness = max( 2 * ft, 3 * in + ceil( roof_rvalue_min / rvalue_per_in_closed_cell_foam) * in);
default_ceiling_height_min = 9 * ft;
default_eaves_overhang = 3 * ft;

default_font = "Comic Sans MS:style=Regular";

exterior_wall_thickness = 5.5 * in + 1.5 * in + 0.5 * in;
interior_wall_thickness = 3.5 * in + 0.5 * in + 0.5 * in;

/* Maindeck */

function maindeck_x() = bedroom2_x() + interior_wall_thickness + stairs_x() + interior_wall_thickness + diningroom_x() + greatroom_x();
function maindeck_y() = 12 * ft;
module position_maindeck() {
    position_lot() {
        translate( building_area_northeast_corner) {
            rotate( [ 0, 0, vector_to_angle( vector_difference( building_area_northeast_corner, building_area_north_corner))]) {
                translate( [ -maindeck_x(), -maindeck_y() - 1 * ft, 0]) {
                    children();
                }
            }
        }
    }
}
module maindeck() {
    position_maindeck() {
        %square( [ maindeck_x(), maindeck_y()]);
    }
}

/* Greatroom */

function greatroom_x() = 22 * ft;
function greatroom_y() = 26 * ft;
module position_greatroom() {
    position_maindeck() {
        translate( [ maindeck_x() - greatroom_x(), -exterior_wall_thickness - greatroom_y()]) {
            children();
        }
    }
}
module greatroom() {
    position_greatroom() {
        square( [ greatroom_x(), greatroom_y()]);
    }
}

/* Kitchen */

function kitchen_x() = 16 * ft;
function kitchen_y() = greatroom_y() - diningroom_y();
module position_kitchen() {
    position_greatroom() {
        translate( [ -kitchen_x(), 0]) {
            children();
        }
    }
}
module kitchen() {
    position_kitchen() {
        square( [ kitchen_x(), kitchen_y()]);
    }
}

/* Diningroom */

function diningroom_x() = kitchen_x();
function diningroom_y() = 12 * ft;
module position_diningroom() {
    position_kitchen() {
        translate( [ 0, kitchen_y()]) {
            children();
        }
    }
}
module diningroom() {
    position_diningroom() {
        square( [ diningroom_x(), diningroom_y()]);
    }
}

/* Stairs */

function stairs_x() = 8 * ft;
function stairs_y() = bedroom2_y();
module position_stairs() {
    position_diningroom() {
        translate( [ -interior_wall_thickness - stairs_x(), diningroom_y() - stairs_y()]) {
            children();
        }
    }
}
module stairs() {
    position_stairs() {
        square( [ stairs_x(), stairs_y()]);
    }
}

/* bedroom2 */

function bedroom2_x() = 15 * ft;
function bedroom2_y() = 15 * ft;
module position_bedroom2() {
    position_stairs() {
        translate( [ -interior_wall_thickness - bedroom2_x(), stairs_y() - bedroom2_y()]) {
            children();
        }
    }
}
module bedroom2() {
    position_bedroom2() {
        square( [ bedroom2_x(), bedroom2_y()]);
    }
}


/* Garage */

function garage_x() = 36 * ft;
function garage_y() = 27 * ft;
module position_garage() {
    position_northwest_wing() {
        children();
    }
}
module garage() {
    position_garage() {
        square( [ garage_x(), garage_y()]);
    }
}


/* Workshop */
function workshop_x() = 12 * ft;
function workshop_y() = mudroom_y() + interior_wall_thickness + northwest_hallway_y();
module position_workshop() {
    position_garage() {
        translate( [ 0, garage_y() + exterior_wall_thickness, 0]) {
            children();
        }
    }
}
module workshop() {
    position_workshop() {
        square( [ workshop_x(), workshop_y()]);
    }
}


/* bathroom2 */

function bathroom2_x() = 8 * ft;
function bathroom2_y() = bedroom2_y();
module position_bathroom2() {
    position_bedroom2() {
        translate( [ bedroom2_x() + interior_wall_thickness, 0]) {
            children();
        }
    }
}
module bathroom2() {
    position_bathroom2() {
        square( [ bathroom2_x(), bathroom2_y()]);
    }
}

/* bedroom2 */

function bedroom2_closet_x() = 3 * ft;
function bedroom2_closet_y() = bedroom2_y();
module position_bedroom2_closet() {
    position_workshop() {
        translate( [ 0, workshop_y() + interior_wall_thickness]) {
            children();
        }
    }
}
module bedroom2_closet() {
    position_bedroom2_closet() {
        square( [ bedroom2_closet_x(), bedroom2_closet_y()]);
    }
}

/* Mudroom */

function mudroom_y() = 8 * ft;
function mudroom_x() = bedroom2_x() + interior_wall_thickness + bedroom2_closet_x() + bathroom2_x() - workshop_x();
module position_mudroom() {
    position_workshop() {
        translate( [ workshop_x() + interior_wall_thickness, 0]) {
            children();
        }
    }
}
module mudroom() {
    position_mudroom() {
        square( [ mudroom_x(), mudroom_y()]);
    }
}

/* Northwest Hallway */

function northwest_hallway_x() = mudroom_x();
function northwest_hallway_y() = 3.5 * ft;
module position_northwest_hallway() {
    position_mudroom() {
        translate( [ 0, mudroom_y() + interior_wall_thickness]) {
            children();
        }
    }
}
module northwest_hallway() {
    position_northwest_hallway() {
        square( [ northwest_hallway_x(), northwest_hallway_y()]);
    }
}

/* Northwest Wing */

function northwest_wing_x() = garage_x();
function northwest_wing_y() = garage_y() + exterior_wall_thickness + workshop_y() + interior_wall_thickness + bedroom2_y();

module position_northwest_wing() {
    position_building_area() {
        translate( [ exterior_wall_thickness, exterior_wall_thickness + 0 * ft]) {
            rotate( [ 0, 0, southwest_boundary_angle - northwest_boundary_angle + 90]) {
            children();
            }
        }
    }
}



function southeast_wing_offset() = 10 * ft;

/* Front_porch */

function front_porch_x() = 5 * ft;
function front_porch_y() = southeast_wing_offset() - exterior_wall_thickness;
module position_front_porch() {
    position_southeast_wing() {
        children();
    }
}
module front_porch() {
    position_front_porch() {
        square( [ front_porch_x(), front_porch_y()]);
    }
}


/* Powder room */

function master_closet_x() = 6 * ft;
function master_closet_y() = southeast_wing_offset() - interior_wall_thickness;
module position_master_closet() {
    position_front_porch() {
        translate( [ front_porch_x() + exterior_wall_thickness, 0]) {
            children();
        }
    }
}
module master_closet() {
    position_master_closet() {
        square( [ master_closet_x(), master_closet_y()]);
    }
}

function southeast_hallway_width() = 3.5 * ft;

/* Master Closet */

function powder_room_x() = master_closet_x() - interior_wall_thickness + exterior_wall_thickness;
function powder_room_y() = master_bedroom_y() - southeast_hallway_width() - interior_wall_thickness;
module position_powder_room() {
    position_entrance_hall() {
        translate( [ entrance_hall_x() + interior_wall_thickness, southeast_hallway_width() + interior_wall_thickness, 0]) {
            children();
        }
    }
}
module powder_room() {
    position_powder_room() {
        square( [ powder_room_x(), powder_room_y()]);
    }
}

/* Master Bedroom */

function master_bedroom_x() = 12 * ft;
function master_bedroom_y() = 12 * ft;
module position_master_bedroom() {
    position_master_bathroom() {
        translate( [ 0, master_bathroom_y() + interior_wall_thickness]) {
            children();
        }
    }
}
module master_bedroom() {
    position_master_bedroom() {
        square( [ master_bedroom_x(), master_bedroom_y()]);
    }
}

/* Southeast_wing */

function southeast_wing_x() = entrance_hall_x() + powder_room_x() + master_bedroom_x() + 2 * interior_wall_thickness;
function southeast_wing_y() = powder_room_y() + southeast_hallway_width() + 2 * interior_wall_thickness + master_closet_y() + exterior_wall_thickness + greatroom_y() + 5 * ft;
module position_southeast_wing() {
    position_garage() {
        translate( [ garage_x() + exterior_wall_thickness, 0]) {
            children();
        }
    }
}

/* Master Bathroom */

function master_bathroom_x() = 12;
function master_bathroom_y() = southeast_wing_y() - master_bedroom_y() - interior_wall_thickness;
module position_master_bathroom() {
    position_master_closet() {
        translate( [ master_closet_x() + interior_wall_thickness, 0]) {
            children();
        }
    }
}
module master_bathroom() {
    position_master_bathroom() {
        square( [ master_bathroom_x(), master_bathroom_y()]);
    }
}

/* Entrance Hall */

function entrance_hall_x() = front_porch_x();
function entrance_hall_y() = southeast_wing_y() - southeast_wing_offset();
module position_entrance_hall() {
    position_front_porch() {
        translate( [ 0, front_porch_y() + exterior_wall_thickness, 0]) {
            children();
        }
    }
}
module entrance_hall() {
    position_entrance_hall() {
        polygon( [ [ 0, 0],
                   [ 0, entrance_hall_y()],
                   [ entrance_hall_x(), entrance_hall_y()],
                   [ entrance_hall_x(), southeast_hallway_width()],
                   [ entrance_hall_x() + exterior_wall_thickness + master_closet_x(), southeast_hallway_width()],
                   [ entrance_hall_x() + exterior_wall_thickness + master_closet_x(), 0]
                   ]);
    }
}

/* Floorplan */

module upperfloor_rooms() {
    maindeck();
    greatroom();
    kitchen();
    diningroom();
    stairs();
    bedroom2();
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
        internal_offset_thickness = max( interior_wall_thickness, exterior_wall_thickness) + 1;
        offset( delta = exterior_wall_thickness - internal_offset_thickness) {
            offset( delta = internal_offset_thickness) {
                upperfloor_rooms();
            }
        }
        upperfloor_rooms();
    }
}

module garage_door_cutouts() {
    position_garage() {
        translate( [ 0, -exterior_wall_thickness - 1 * in, 0]) {
            translate( [ 4 * ft, 0, 0]) {
                cube( [ 16 * ft, exterior_wall_thickness + 2 * in, 7 * ft]);
            }
            translate( [ 24 * ft, 0, 0]) {
                cube( [ 9 * ft, exterior_wall_thickness + 2 * in, 7 * ft]);
            }
        }
    }
}

module workshop_door_cutouts() {
    position_workshop() {
        door_width = 36 * in;
        translate( [ workshop_x() - 4 * ft, -exterior_wall_thickness - 1 * in, 0]) {
            cube( [ door_width, exterior_wall_thickness + 2 * in, 80 * in]);
        }
    }
}

module mudroom_door_cutouts() {
    position_mudroom() {
        door_width = 36 * in;
        translate( [ 1 * ft, -exterior_wall_thickness - 1 * in, 0]) {
            cube( [ door_width, exterior_wall_thickness + 2 * in, 80 * in]);
        }
        translate( [ mudroom_x() - 4 * ft, mudroom_y() - 1 * in, 0]) {
            cube( [ door_width, exterior_wall_thickness + 2 * in, 80 * in]);
        }
    }
}

module northwest_hallway_cutout() {
    difference() {
        position_northwest_hallway() {
            translate( [ northwest_hallway_x() - 1 * in, 0, 0]) {
                cube( [ exterior_wall_thickness + 2 * in, northwest_hallway_y(), roof_height_max + 1 * in]);
            }
        }
        position_greatroom_roof() {
            shed_roof_cutout( greatroom_roof_spec());
        }
    }
}

module greatroom_cutouts() {
    difference() {
        union() {
            position_northwest_hallway() {
                translate( [ northwest_hallway_x() - 1 * in, 0, 0]) {
                    cube( [ exterior_wall_thickness + 2 * in, northwest_hallway_y(), roof_height_max + 1 * in]);
                }
            }
            position_entrance_hall() {
                translate( [ -exterior_wall_thickness - 1 * in, 0, 0]) {
                    cube( [ exterior_wall_thickness + 2 * in, entrance_hall_y(), roof_height_max + 1 * in]);
                }
            }
        }
        position_greatroom_roof() {
            shed_roof_cutout( greatroom_roof_spec());
        }
    }
}

module main_entrance_cutouts() {
    position_entrance_hall() {
        door_width = 36 * in;
        translate( [ ( front_porch_x() - door_width) / 2, -exterior_wall_thickness - 1 * in, 0]) {
            cube( [ door_width, exterior_wall_thickness + 2 * in, 80 * in]);
        }
    }
}

module powder_room_cutouts() {
    position_powder_room() {
        door_width = 28 * in;
        translate( [ powder_room_x() - 6 * in - door_width, -interior_wall_thickness - 1 * in, 0]) {
            cube( [ door_width, interior_wall_thickness + 2 * in, 80 * in]);
        }
    }
}

module master_bedroom_cutouts() {
    position_master_bedroom() {
        door_width = 32 * in;
        translate( [ -interior_wall_thickness - 1 * in, ( southeast_hallway_width() - door_width) / 2, 0]) {
            cube( [ interior_wall_thickness + 2 * in, door_width, 80 * in]);
        }
    }
}

module door_cutouts() {
    garage_door_cutouts();
    workshop_door_cutouts();
    mudroom_door_cutouts();
    greatroom_cutouts();
    main_entrance_cutouts();
    powder_room_cutouts();
    master_bedroom_cutouts();
}


/* Northwest section roof */

function northwest_wing_roof_overhang() = default_eaves_overhang;
function northwest_wing_roof_x() = northwest_wing_x() + 2 * exterior_wall_thickness + 2 * northwest_wing_roof_overhang();
function northwest_wing_roof_y() = northwest_wing_y() + 2 * exterior_wall_thickness + 2 * northwest_wing_roof_overhang();

function northwest_wing_roof_spec() = shed_roof_spec_from_slope(
        sloped_span = northwest_wing_roof_x(),
        flat_span = northwest_wing_roof_y(),
        slope = 3.0 / 12,
        max_roof_height = roof_height_max,
        thickness = roof_thickness);

module position_northwest_wing_roof() {
    position_garage() {
        translate( [ -northwest_wing_roof_overhang() - exterior_wall_thickness, -northwest_wing_roof_overhang() - exterior_wall_thickness, 0]) {
            children();
        }
    }
}

module northwest_wing_roof() {
    difference() {
        position_northwest_wing_roof() {
            shed_roof( northwest_wing_roof_spec());
        }
/*
        position_greatroom() {
            translate( [ -exterior_wall_thickness / 2 - 1 * in, -exterior_wall_thickness - greatroom_roof_overhang, 0]) {
                cube( [ greatroom_x() + exterior_wall_thickness / 2 + 1 * in, greatroom_y() + exterior_wall_thickness + greatroom_roof_overhang, roof_height_max + 1 * in]);
            }
        }
*/
        position_northwest_wing_roof() {
            translate( [ -1 * in, garage_y() + 2 * exterior_wall_thickness + 2 * northwest_wing_roof_overhang(), 0]) {
                cube( [ garage_x() - workshop_x() - interior_wall_thickness - mudroom_x() + 1 * in, northwest_wing_y() + 1 * in, roof_height_max + 1 * in]);
            }
        }
    }
    echo_shed_roof_spec( "northwest section", northwest_wing_roof_spec(), low_overhang = northwest_wing_roof_overhang() + exterior_wall_thickness);
}

module northwest_wing_roof_cutout() {
    position_northwest_wing_roof() {
        shed_roof_cutout( northwest_wing_roof_spec());
    }
}

/* Greatroom roof */
/*
greatroom_roof_overhang = default_eaves_overhang;
greatroom_roof_x() = greatroom_roof_overhang * 2 + exterior_wall_thickness * 2 + greatroom_x;
greatroom_roof_y() = greatroom_roof_overhang * 2 + exterior_wall_thickness * 2 + greatroom_y;

greatroom_roof_spec = shed_roof_spec_from_slope(
        sloped_span = greatroom_roof_x,
        flat_span = greatroom_roof_y,
        slope = 3.0 / 12,
        max_roof_height = roof_height_max,
        thickness = roof_thickness);

module position_greatroom_roof() {
    position_greatroom() {
        translate( [ greatroom_roof_x() - greatroom_roof_overhang - exterior_wall_thickness, -greatroom_roof_overhang - exterior_wall_thickness, 0]) {
            mirror( [ 1, 0, 0]) {
                children();
            }
        }
    }
}

module greatroom_roof() {
    position_greatroom_roof() {
        shed_roof( greatroom_roof_spec);
        echo_shed_roof_spec( "southeast section", greatroom_roof_spec);
    }
}

module greatroom_roof_cutout() {
    position_greatroom_roof() {
        shed_roof_cutout( greatroom_roof_spec);
    }
}
*/

function greatroom_roof_overhang() = default_eaves_overhang;
function greatroom_roof_x() = greatroom_x() + 2 * exterior_wall_thickness + 2 * greatroom_roof_overhang() + southeast_wing_x();
function greatroom_roof_y() = greatroom_y() + 2 * exterior_wall_thickness + 2 * greatroom_roof_overhang();

function greatroom_roof_spec() = shed_roof_spec_from_slope(
        sloped_span = greatroom_roof_y(),
        flat_span = greatroom_roof_x(),
        slope = 3.0 / 12,
        max_roof_height = roof_height_max,
        thickness = roof_thickness);

module position_greatroom_roof() {
    position_greatroom() {
        translate( [ greatroom_roof_x() - exterior_wall_thickness - greatroom_roof_overhang(), -greatroom_roof_overhang() - exterior_wall_thickness, 0]) {
            rotate( [ 0, 0, 90]) {
                children();
            }
        }
    }
}

module greatroom_roof_notches() {
    translate( [ -1 * in, -1 * in, 0]) {
        cube( [ southeast_wing_y() - southeast_wing_offset() + 2 * exterior_wall_thickness + greatroom_roof_overhang() + 1 * in, greatroom_roof_overhang() + exterior_wall_thickness + 1 * in, roof_height_max + 1 * in]);
    }
    translate( [ -1 * in, greatroom_roof_x() - greatroom_roof_overhang() - exterior_wall_thickness, 0]) {
        cube( [ northwest_wing_y() - greatroom_offset() + 2 * exterior_wall_thickness + greatroom_roof_overhang() + 1 * in, greatroom_roof_overhang() + exterior_wall_thickness + 1 * in, roof_height_max + 1 * in]);
    }
}

module greatroom_roof() {
    position_greatroom_roof() {
        difference() {
            shed_roof( greatroom_roof_spec());
            greatroom_roof_notches();
        }
        echo_shed_roof_spec( "southeast section", greatroom_roof_spec(), low_overhang = exterior_wall_thickness + greatroom_roof_overhang());
    }
}

module greatroom_roof_cutout() {
    position_greatroom_roof() {
        difference() {
            shed_roof_cutout( greatroom_roof_spec());
            greatroom_roof_notches();
        }
    }
}


/* Southeast_wing roof */

function southeast_wing_roof_overhang() = default_eaves_overhang;
function southeast_wing_roof_x() = southeast_wing_roof_overhang() + exterior_wall_thickness + southeast_wing_x();
function southeast_wing_roof_y() = southeast_wing_roof_overhang() * 2 + exterior_wall_thickness * 2 + southeast_wing_y();

function southeast_wing_roof_spec() = shed_roof_spec_from_slope(
        sloped_span = southeast_wing_roof_x(),
        flat_span = southeast_wing_roof_y(),
        slope = 3.0 / 12,
        max_roof_height = roof_height_max - shed_roof_vertical_thickness( northwest_wing_roof_spec()) - 3 * ft,
        thickness = roof_thickness);

module position_southeast_wing_roof() {
    position_southeast_wing() {
        translate( [ southeast_wing_roof_x(), -southeast_wing_roof_overhang() - exterior_wall_thickness, 0]) {
            mirror( [ 1, 0, 0]) {
                children();
            }
        }
    }
}

module southeast_wing_roof() {
    position_southeast_wing_roof() {
        shed_roof( southeast_wing_roof_spec());
        echo_shed_roof_spec( "southeast section", southeast_wing_roof_spec());
    }
}

module southeast_wing_roof_cutout() {
    position_southeast_wing_roof() {
        shed_roof_cutout( southeast_wing_roof_spec(), extra_height = roof_height_max - shed_roof_max_roof_height( southeast_wing_roof_spec()) + 1 * in);
    }
}


/* Middle section roof */
/*
middle_section_roof_overhang = default_eaves_overhang;
middle_section_roof_x() = middle_section_x() + 2 * exterior_wall_thickness;
middle_section_roof_y() = middle_section_roof_overhang * 2 + exterior_wall_thickness * 2 + middle_section_y;
middle_section_roof_max_height = roof_height_max - max( shed_roof_vertical_thickness( northwest_wing_roof_spec()), shed_roof_vertical_thickness( southeast_section_roof_spec)) - 1 * ft;

middle_section_roof_spec = shed_roof_spec_from_slope(
        sloped_span = middle_section_roof_y,
        flat_span = middle_section_roof_x() - 2 * exterior_wall_thickness,
        slope = 3.0 / 12,
        max_roof_height = middle_section_roof_max_height,
        thickness = roof_thickness);

module position_middle_section_roof() {
    position_middle_section() {
        translate( [ middle_section_roof_x() - 2 * exterior_wall_thickness, -middle_section_roof_overhang - exterior_wall_thickness, 0]) {
            rotate( [ 0, 0, 90]) {
                children();
            }
        }
    }
}

module middle_section_roof() {
    position_middle_section_roof() {
        shed_roof( middle_section_roof_spec);
        echo_shed_roof_spec( "middle section", middle_section_roof_spec);
    }
}

module middle_section_roof_cutout() {
    position_middle_section_roof() {
        shed_roof_cutout( middle_section_roof_spec, extra_height = roof_height_max - middle_section_roof_max_height + 1 * in);
    }
}
*/

/* Complete Roof */

module roof() {
    northwest_wing_roof();
//    middle_section_roof();
    greatroom_roof();
//    southeast_wing_roof();
}

module upperfloor_walls() {
    render() {
        difference() {
            linear_extrude( roof_height_max) {
                upperfloor_walls_2d();
            }
            northwest_wing_roof_cutout();
//            middle_section_roof_cutout();
            greatroom_roof_cutout();
//            southeast_wing_roof_cutout();
            door_cutouts();
        }
    }
}

module house() {
    color( "tan", 1) {
        upperfloor_walls();
    }
    color( "darkslategray", 0.5) {
        roof();
    }
}

module house_2d() {
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

//house();
//house_2d();

%building_area_lines();
%lot_lines();
%rock();
%bigtree();
%meter();
upperfloor_rooms();
