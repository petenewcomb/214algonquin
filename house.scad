include <floorplan.scad>;
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

/*
exterior_wall_thickness = max( 3 * in + 5.5 * in, 3 * in + ceil( exterior_wall_rvalue_min / rvalue_per_in_fiberglass) * in);

module make_envelope( roof_spec, depth = 0, wall_offset = 0, extra_height = 0, extra_depth = 0) {
    width = ceiling_span_sloped( roof_spec) - 2 * wall_offset;
    length = ceiling_span_flat( roof_spec) - 2 * wall_offset;
    make_room( length, width, wall_offset, wall_offset, roof_spec, depth, extra_height, extra_depth);
}

module make_room( length, width, length_offset, width_offset, roof_spec, depth = 0, extra_height = 0, extra_depth = 0) {
    height_min = ceiling_height_min( roof_spec, width_offset) + extra_height + extra_depth;
    height_max = ceiling_height_max( roof_spec, ceiling_span_sloped( roof_spec) - width - width_offset) + extra_height + extra_depth;
    translate( [ width_offset, length + length_offset, -extra_depth]) {
        rotate( [ 90, 0, 0]) {
            linear_extrude( length) {
                polygon( [ [ width, height_max],
                           [ width, -depth],
                           [ 0, -depth],
                           [ 0, height_min]]);
            }
        }
    }
}
*/

/* Garage */
/*
garage_width = 40 * ft;
garage_length = 35 * ft;
garage_depth = 0 * ft;

garage_roof_spec = [
    default_eaves_overhang,  // overhang_span_low
    default_ceiling_height_min,          // ceiling_height_min
    garage_length,    // ceiling_span_sloped
    default_eaves_overhang,  // overhang_span_high
    roof_height_max, // roof_height_max
    default_eaves_overhang,  // overhang_span_near
    garage_width,   // ceiling_span_flat
    default_eaves_overhang   // overhang_span_far
];
echo_roof_slope( "garage", garage_roof_spec);

module position_garage() {
    translate( [ 0, -garage_width, 0]) {
        children();
    }
}

module position_garage_children() {
    translate( [ garage_length, 0, 0]) {
        children();
    }
}

module garage_roof() {
    position_garage() make_roof( garage_roof_spec);
    position_garage_children() children();
}

module garage_envelope( wall_offset = 0, extra_height = 0, extra_depth = 0) {
    position_garage() make_envelope( garage_roof_spec, garage_depth, wall_offset, extra_height, extra_depth);
    position_garage_children() children();
}
*/

/* Connector */

/*
connector_width = 30 * ft;
connector_length = 20 * ft;
connector_depth = basement_depth;

connector_roof_spec = [
    default_eaves_overhang,   // overhang_span_low
    default_ceiling_height_min,          // ceiling_height_min
    connector_width,     // ceiling_span_sloped
    default_eaves_overhang,   // overhang_span_high
    ceiling_height_max( garage_roof_spec) - 1 * ft, // roof_height_max
    exterior_wall_thickness,                // overhang_span_near
    connector_length, // ceiling_span_flat
    exterior_wall_thickness                 // overhang_span_far
];

echo_roof_slope( "connector", connector_roof_spec);

module position_connector() {
    translate( [ connector_length, -connector_width, 0]) {
        rotate( [ 0, 0, 90]) {
            children();
        }
    }
}

module position_connector_children() {
    translate( [ connector_length, 0, 0]) {
        children();
    }
}

module connector_roof() {
    position_connector() make_roof( connector_roof_spec);
    position_connector_children() children();
}

module connector_envelope( wall_offset = 0, extra_height = 0, extra_depth = 0) {
    translate( [ -1 * in - 2 * wall_offset, 0, 0]) {
        position_connector() make_envelope( connector_roof_spec, 0, wall_offset, extra_height, extra_depth);
    }
    translate( [ 1 * in + 2 * wall_offset, 0, 0]) {
        position_connector() make_envelope( connector_roof_spec, connector_depth, wall_offset, extra_height, extra_depth);
    }
    position_connector() make_envelope( connector_roof_spec, connector_depth, wall_offset, extra_height, extra_depth);
    position_connector_children() children();
}
*/

/* Mainhouse */

/*
mainhouse_width = garage_width;
mainhouse_length = garage_length;
mainhouse_depth = basement_depth;

mainhouse_roof_spec = [
    default_eaves_overhang,  // overhang_span_low
    default_ceiling_height_min,          // ceiling_height_min
    mainhouse_length,    // ceiling_span_sloped
    default_eaves_overhang,  // overhang_span_high
    roof_height_max, // roof_height_max
    default_eaves_overhang,  // overhang_span_near
    mainhouse_width,   // ceiling_span_flat
    default_eaves_overhang   // overhang_span_far
];

echo_roof_slope( "mainhouse", mainhouse_roof_spec);

module position_mainhouse() {
    translate( [ mainhouse_length, -connector_width, 0]) {
        mirror( [ 1, 0, 0]) {
            children();
        }
    }
}

module position_mainhouse_children() {
    translate( [ mainhouse_length, 0, 0]) {
        children();
    }
}

module mainhouse_roof() {
    position_mainhouse() make_roof( mainhouse_roof_spec);
    position_mainhouse_children() children();
}

module mainhouse_envelope( wall_offset = 0, extra_height = 0, extra_depth = 0) {
    position_mainhouse() make_envelope( mainhouse_roof_spec, mainhouse_depth, wall_offset, extra_height, extra_depth);
    position_mainhouse_children() children();
}
*/

/* Entrance */

/*
entrance_width = 8 * ft;
entrance_length = 8 * ft;
entrance_offset = 3 * ft;

entrance_roof_spec = [
    0,  // overhang_span_low
    default_ceiling_height_min,          // ceiling_height_min
    entrance_length,    // ceiling_span_sloped
    0,  // overhang_span_high
    default_ceiling_height_min + roof_thickness_vertical( mainhouse_roof_spec) + entrance_length * roof_slope( mainhouse_roof_spec, granularity = 0), // roof_height_max
    0,  // overhang_span_near
    entrance_width,   // ceiling_span_flat
    0   // overhang_span_far
];
echo_roof_slope( "entrance", entrance_roof_spec);

module position_entrance() {
    translate( [ entrance_offset + entrance_length, -connector_width - entrance_width, 0]) {
        mirror( [ 1, 0, 0]) {
            children();
        }
    }
}

module position_entrance_children() {
    translate( [ entrance_offset + entrance_length, 0, 0]) {
        children();
    }
}

module entrance_roof() {
    position_entrance() make_roof( entrance_roof_spec);
    position_entrance_children() children();
}
*/

/* Whole house */

module upperfloor_walls() {
    render() {
        difference() {
            linear_extrude( roof_height_max) {
                upperfloor_walls_2d();
            }
            northwest_garage_roof_cutout();
            northwest_connector_roof_cutout();
        }
    }
}

northwest_garage_roof_overhang = default_eaves_overhang;
northwest_garage_roof_x = northwest_garage_roof_overhang * 2 + exterior_wall_thickness * 2 + northwest_garage_x;
northwest_garage_roof_y = northwest_garage_roof_overhang * 2 + exterior_wall_thickness * 3 + northwest_garage_y + workshop_y;

northwest_garage_roof_spec = shed_roof_spec_from_slope(
        sloped_span = northwest_garage_roof_x,
        flat_span = northwest_garage_roof_y,
        slope = 3.0 / 12,
        max_roof_height = roof_height_max,
        thickness = roof_thickness);
echo( northwest_garage_roof_spec);

module position_northwest_garage_roof() {
    position_northwest_garage() {
        translate( [ -northwest_garage_roof_overhang - exterior_wall_thickness, -northwest_garage_roof_overhang - exterior_wall_thickness, 0]) {
            children();
        }
    }
}

module northwest_garage_roof() {
    position_northwest_garage_roof() {
        shed_roof( northwest_garage_roof_spec);
        echo_shed_roof_spec( "northwest garage", northwest_garage_roof_spec);
    }
}

module northwest_garage_roof_cutout() {
    position_northwest_garage_roof() {
        shed_roof_cutout( northwest_garage_roof_spec);
    }
}

northwest_connector_roof_overhang = default_eaves_overhang;
northwest_connector_roof_x = northwest_connector_x;
northwest_connector_roof_y = northwest_connector_roof_overhang * 2 + exterior_wall_thickness * 2 + northwest_connector_y;
northwest_connector_roof_height_reduction = 4 * ft;
northwest_connector_roof_spec = shed_roof_spec_from_slope(
        sloped_span = northwest_connector_roof_y,
        flat_span = northwest_connector_roof_x,
        slope = 3.0 / 12,
        max_roof_height = roof_height_max - northwest_connector_roof_height_reduction,
        thickness = roof_thickness);
echo( northwest_connector_roof_spec);

module position_northwest_connector_roof() {
    position_northwest_connector() {
        translate( [ northwest_connector_roof_x, -northwest_connector_roof_overhang - exterior_wall_thickness, 0]) {
            rotate( [ 0, 0, 90]) {
                children();
            }
        }
    }
}

module northwest_connector_roof() {
    position_northwest_connector_roof() {
        shed_roof( northwest_connector_roof_spec);
    }
}

module northwest_connector_roof_cutout() {
    position_northwest_connector_roof() {
        shed_roof_cutout( northwest_connector_roof_spec, extra_height = northwest_connector_roof_height_reduction + 1 * in);
    }
}

module roof() {
    northwest_garage_roof();
    northwest_connector_roof();
/*
    connector_roof() {
        mainhouse_roof();
        entrance_roof();
    }
*/
}

module exterior_walls() {
    difference() {
        envelope();
        envelope( exterior_wall_thickness, extra_height = 1 * in, extra_depth = 1 * in);
    }
}

module house() {
    upperfloor_walls();
//    exterior_walls();
    %roof();
}

rotate( [ 0, 0, -southwest_boundary_angle]) {
    translate( vector_difference( [0, 0], building_area_west_corner)) {
        house();
    }
}
//floor_plans();
/*
difference() {
    envelope();
    position_garage_children()
    position_connector_children()
    position_mainhouse() {
        bedroom_width = 12 * ft;
        bedroom_length = 15 * ft;
        make_room( bedroom_length, bedroom_width, mainhouse_width - exterior_wall_thickness - bedroom_length, exterior_wall_thickness, mainhouse_roof_spec, extra_height = 1 * in);
    }
}
*/
