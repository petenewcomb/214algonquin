include <floorplan3.scad>;
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

// Northwest section roof */

northwest_section_roof_overhang = default_eaves_overhang;
northwest_section_roof_x = northwest_section_roof_overhang * 2 + exterior_wall_thickness * 2 + northwest_section_x;
northwest_section_roof_y = northwest_section_roof_overhang * 2 + exterior_wall_thickness * 2 + northwest_section_y;

northwest_section_roof_spec = shed_roof_spec_from_slope(
        sloped_span = northwest_section_roof_y / 2 + exterior_wall_thickness + northwest_section_roof_overhang,
        flat_span = northwest_section_roof_x,
        slope = 3.0 / 12,
        max_roof_height = roof_height_max,
        thickness = roof_thickness);

module position_northwest_section_roof() {
    position_northwest_section() {
        translate( [ -northwest_section_roof_overhang - exterior_wall_thickness, -northwest_section_roof_overhang - exterior_wall_thickness, 0]) {
            children();
        }
    }
}

module northwest_section_roof() {
    position_northwest_section_roof() {
        translate( [ northwest_section_roof_x, 0, 0]) {
            rotate( [ 0, 0, 90]) {
                shed_roof( northwest_section_roof_spec);
            }
        }
        translate( [ 0, northwest_section_roof_y / 2 - northwest_section_roof_overhang - exterior_wall_thickness, 0]) {
//            rotate( [ 0, 0, -90]) {
                shed_roof( northwest_section_roof_spec);
//            }
        }
        echo_shed_roof_spec( "northwest section", northwest_section_roof_spec);
    }
}

module northwest_section_roof_cutout() {
    position_northwest_section_roof() {
        translate( [ northwest_section_roof_x, 0, 0]) {
            rotate( [ 0, 0, 90]) {
                shed_roof_cutout( northwest_section_roof_spec);
            }
        }
        translate( [ 0, northwest_section_roof_y, 0]) {
            rotate( [ 0, 0, -90]) {
                shed_roof_cutout( northwest_section_roof_spec);
            }
        }
    }
}

// Southeast section roof */

southeast_section_roof_overhang = default_eaves_overhang;
southeast_section_roof_x = southeast_section_roof_overhang * 2 + exterior_wall_thickness * 2 + southeast_section_x;
southeast_section_roof_y = southeast_section_roof_overhang * 2 + exterior_wall_thickness * 2 + southeast_section_y;

southeast_section_roof_spec = shed_roof_spec_from_slope(
        sloped_span = southeast_section_roof_x,
        flat_span = southeast_section_roof_y,
        slope = 3.0 / 12,
        max_roof_height = roof_height_max,
        thickness = roof_thickness);

module position_southeast_section_roof() {
    position_southeast_section() {
        translate( [ southeast_section_roof_x - southeast_section_roof_overhang - exterior_wall_thickness, -southeast_section_roof_overhang - exterior_wall_thickness, 0]) {
            mirror( [ 1, 0, 0]) {
                children();
            }
        }
    }
}

module southeast_section_roof() {
    position_southeast_section_roof() {
        shed_roof( southeast_section_roof_spec);
        echo_shed_roof_spec( "southeast section", southeast_section_roof_spec);
    }
}

module southeast_section_roof_cutout() {
    position_southeast_section_roof() {
        shed_roof_cutout( southeast_section_roof_spec);
    }
}

module upperfloor_walls() {
    render() {
        difference() {
            linear_extrude( roof_height_max) {
                upperfloor_walls_2d();
            }
            northwest_section_roof_cutout();
            middle_section_roof_cutout();
            southeast_section_roof_cutout();
        }
    }
}

// Middle section roof */

middle_section_roof_overhang = default_eaves_overhang;
middle_section_roof_x = middle_section_x + 2 * exterior_wall_thickness;
middle_section_roof_y = middle_section_roof_overhang * 2 + exterior_wall_thickness * 2 + middle_section_y;
middle_section_roof_max_height = roof_height_max - max( shed_roof_vertical_thickness( northwest_section_roof_spec), shed_roof_vertical_thickness( southeast_section_roof_spec)) - 1 * ft;

middle_section_roof_spec = shed_roof_spec_from_slope(
        sloped_span = middle_section_roof_y,
        flat_span = middle_section_roof_x - 2 * exterior_wall_thickness,
        slope = 3.0 / 12,
        max_roof_height = middle_section_roof_max_height,
        thickness = roof_thickness);

module position_middle_section_roof() {
    position_middle_section() {
        translate( [ middle_section_roof_x - 2 * exterior_wall_thickness, -middle_section_roof_overhang - exterior_wall_thickness, 0]) {
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

/* Complete Roof */

module roof() {
    northwest_section_roof();
    middle_section_roof();
    southeast_section_roof();
}

module house() {
    upperfloor_walls();
    %roof();
}

position_building_area() {
    house();
}

%building_area_lines();
%rock();
%bigtree();
%meter();
