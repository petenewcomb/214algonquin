include <floorplan6.scad>;
include <shed_roof.scad>;

basement_depth = 10 * ft;
roof_height_max = 30 * ft - basement_depth;

roof_rvalue_min = 49;
exterior_wall_rvalue_min = 21;
rvalue_per_in_closed_cell_foam = 6.5;
rvalue_per_in_fiberglass = 3;

roof_thickness = max( 2 * ft, 3 * in + ceil( roof_rvalue_min / rvalue_per_in_closed_cell_foam) * in);
default_ceiling_height_min = 9 * ft;
default_eaves_overhang = 2 * ft;

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

house();
//house_2d();

%building_area_lines();
%rock();
%bigtree();
%meter();
%lot_lines();
