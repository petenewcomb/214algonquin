include <units.scad>;
include <lot.scad>;
include <building_area.scad>;
include <MCAD/2Dshapes.scad>;

default_font = "Comic Sans MS:style=Regular";

exterior_wall_thickness = 5.5 * in + 1.5 * in + 0.5 * in;
interior_wall_thickness = 3.5 * in + 0.5 * in + 0.5 * in;

/* Northwest section */

northwest_section_x = 30 * ft;
northwest_section_y = 60 * ft;
module position_northwest_section() {
//    position_building() {
//        translate( [ greatroom_x - northwest_section_x, greatroom_y - northwest_section_y]) {
            children();
//        }
//    }
}
module northwest_section() {
    position_northwest_section() {
        square( [ northwest_section_x, northwest_section_y]);
    }
}


/* Middle section */

middle_section_x = 25 * ft;
middle_section_y = 20 * ft;
module position_middle_section() {
    position_northwest_section() {
        translate( [ northwest_section_x + exterior_wall_thickness, 5 * ft]) {
            children();
        }
    }
}
module middle_section() {
    position_middle_section() {
        square( [ middle_section_x, middle_section_y]);
    }
}


/* Southeast section */

southeast_section_x = 30 * ft;
southeast_section_y = 55 * ft;
module position_southeast_section() {
    position_northwest_section() {
        translate( [ northwest_section_x + middle_section_x + 2 * exterior_wall_thickness, -9 * ft]) {
            children();
        }
    }
}
module southeast_section() {
    position_southeast_section() {
        square( [ southeast_section_x, southeast_section_y]);
    }
}


/* Floorplan */

module upperfloor_rooms() {
    northwest_section();
    middle_section();
    southeast_section();
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
