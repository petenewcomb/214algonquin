use <math.scad>;
use <units.scad>;
use <constants.scad>;
use <lot.scad>;
use <building_area.scad>;
use <greatroom.scad>;

use <shed_roof.scad>;
use <building_area.scad>;
//include <MCAD/2Dshapes.scad>;

use <main_deck.scad>;
use <greatroom.scad>;
use <stairs.scad>;
use <bedroom2.scad>;
use <diningroom.scad>;

/* Garage */

function garage_x() = feet( 36);
function garage_y() = feet( 27);
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
function workshop_x() = feet( 12);
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

function bathroom2_x() = feet( 8);
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

function bedroom2_closet_x() = feet( 3);
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

function mudroom_y() = feet( 8);
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
function northwest_hallway_y() = feet( 3.5);
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
        translate( [ exterior_wall_thickness, exterior_wall_thickness + feet( 0)]) {
            rotate( [ 0, 0, southwest_boundary_angle - northwest_boundary_angle + 90]) {
            children();
            }
        }
    }
}



function southeast_wing_offset() = feet( 10);

/* Front_porch */

function front_porch_x() = feet( 5);
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

function master_closet_x() = feet( 6);
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

function southeast_hallway_width() = feet( 3.5);

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

function master_bedroom_x() = feet( 12);
function master_bedroom_y() = feet( 12);
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
function southeast_wing_y() = powder_room_y() + southeast_hallway_width() + 2 * interior_wall_thickness + master_closet_y() + exterior_wall_thickness + greatroom_y() + feet( 5);
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


module garage_door_cutouts() {
    position_garage() {
        translate( [ 0, -exterior_wall_thickness - inches( 1), 0]) {
            translate( [ feet( 4), 0, 0]) {
                cube( [ feet( 16), exterior_wall_thickness + inches( 2), feet( 7)]);
            }
            translate( [ feet( 24), 0, 0]) {
                cube( [ feet( 9), exterior_wall_thickness + inches( 2), feet( 7)]);
            }
        }
    }
}

module workshop_door_cutouts() {
    position_workshop() {
        door_width = inches( 36);
        translate( [ workshop_x() - feet( 4), -exterior_wall_thickness - inches( 1), 0]) {
            cube( [ door_width, exterior_wall_thickness + inches( 2), inches( 80)]);
        }
    }
}

module mudroom_door_cutouts() {
    position_mudroom() {
        door_width = inches( 36);
        translate( [ feet( 1), -exterior_wall_thickness - inches( 1), 0]) {
            cube( [ door_width, exterior_wall_thickness + inches( 2), inches( 80)]);
        }
        translate( [ mudroom_x() - feet( 4), mudroom_y() - inches( 1), 0]) {
            cube( [ door_width, exterior_wall_thickness + inches( 2), inches( 80)]);
        }
    }
}

module northwest_hallway_cutout() {
    difference() {
        position_northwest_hallway() {
            translate( [ northwest_hallway_x() - inches( 1), 0, 0]) {
                cube( [ exterior_wall_thickness + inches( 2), northwest_hallway_y(), roof_height_max + inches( 1)]);
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
                translate( [ northwest_hallway_x() - inches( 1), 0, 0]) {
                    cube( [ exterior_wall_thickness + inches( 2), northwest_hallway_y(), roof_height_max + inches( 1)]);
                }
            }
            position_entrance_hall() {
                translate( [ -exterior_wall_thickness - inches( 1), 0, 0]) {
                    cube( [ exterior_wall_thickness + inches( 2), entrance_hall_y(), roof_height_max + inches( 1)]);
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
        door_width = inches( 36);
        translate( [ ( front_porch_x() - door_width) / 2, -exterior_wall_thickness - inches( 1), 0]) {
            cube( [ door_width, exterior_wall_thickness + inches( 2), inches( 80)]);
        }
    }
}

module powder_room_cutouts() {
    position_powder_room() {
        door_width = inches( 28);
        translate( [ powder_room_x() - inches( 6) - door_width, -interior_wall_thickness - inches( 1), 0]) {
            cube( [ door_width, interior_wall_thickness + inches( 2), inches( 80)]);
        }
    }
}

module master_bedroom_cutouts() {
    position_master_bedroom() {
        door_width = inches( 32);
        translate( [ -interior_wall_thickness - inches( 1), ( southeast_hallway_width() - door_width) / 2, 0]) {
            cube( [ interior_wall_thickness + inches( 2), door_width, inches( 80)]);
        }
    }
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
            translate( [ -exterior_wall_thickness / 2 - inches( 1), -exterior_wall_thickness - greatroom_roof_overhang, 0]) {
                cube( [ greatroom_x() + exterior_wall_thickness / 2 + inches( 1), greatroom_y() + exterior_wall_thickness + greatroom_roof_overhang, roof_height_max + inches( 1)]);
            }
        }
*/
        position_northwest_wing_roof() {
            translate( [ -inches( 1), garage_y() + 2 * exterior_wall_thickness + 2 * northwest_wing_roof_overhang(), 0]) {
                cube( [ garage_x() - workshop_x() - interior_wall_thickness - mudroom_x() + inches( 1), northwest_wing_y() + inches( 1), roof_height_max + inches( 1)]);
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
    translate( [ -inches( 1), -inches( 1), 0]) {
        cube( [ southeast_wing_y() - southeast_wing_offset() + 2 * exterior_wall_thickness + greatroom_roof_overhang() + inches( 1), greatroom_roof_overhang() + exterior_wall_thickness + inches( 1), roof_height_max + inches( 1)]);
    }
    translate( [ -inches( 1), greatroom_roof_x() - greatroom_roof_overhang() - exterior_wall_thickness, 0]) {
        cube( [ northwest_wing_y() - greatroom_offset() + 2 * exterior_wall_thickness + greatroom_roof_overhang() + inches( 1), greatroom_roof_overhang() + exterior_wall_thickness + inches( 1), roof_height_max + inches( 1)]);
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
        max_roof_height = roof_height_max - shed_roof_vertical_thickness( northwest_wing_roof_spec()) - feet( 3),
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
        shed_roof_cutout( southeast_wing_roof_spec(), extra_height = roof_height_max - shed_roof_max_roof_height( southeast_wing_roof_spec()) + inches( 1));
    }
}


/* Middle section roof */
/*
middle_section_roof_overhang = default_eaves_overhang;
middle_section_roof_x() = middle_section_x() + 2 * exterior_wall_thickness;
middle_section_roof_y() = middle_section_roof_overhang * 2 + exterior_wall_thickness * 2 + middle_section_y;
middle_section_roof_max_height = roof_height_max - max( shed_roof_vertical_thickness( northwest_wing_roof_spec()), shed_roof_vertical_thickness( southeast_section_roof_spec)) - feet( 1);

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
        shed_roof_cutout( middle_section_roof_spec, extra_height = roof_height_max - middle_section_roof_max_height + inches( 1));
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

//house();

%building_area_lines();
%lot_lines();
%rock();
%bigtree();
%meter();
upperfloor_rooms();
