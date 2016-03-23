in = 1 / 12.0;
ft = 12 * in;

basement_depth = 10 * ft;
roof_height_max = 30 * ft - basement_depth;

roof_rvalue_min = 49;
exterior_wall_rvalue_min = 21;
rvalue_per_in_closed_cell_foam = 6.5;
rvalue_per_in_fiberglass = 3;

roof_thickness = max( 2 * ft, 3 * in + ceil( roof_rvalue_min / rvalue_per_in_closed_cell_foam) * in);
default_ceiling_height_min = 9 * ft;
default_eaves_overhang = 2 * ft;

exterior_wall_thickness = max( 3 * in + 5.5 * in, 3 * in + ceil( exterior_wall_rvalue_min / rvalue_per_in_fiberglass) * in);


/* Roof specification vector:
   [ overhang_span_low,
     ceiling_height_min,
     ceiling_span_sloped,
     overhang_span_high,
     roof_height_max,
     overhang_span_near,
     ceiling_span_flat,
     overhang_span_far ]
*/
function roof_spec_overhang_span_low( roof_spec) = roof_spec[ 0];
function roof_spec_ceiling_height_min( roof_spec) = roof_spec[ 1];
function roof_spec_ceiling_span_sloped( roof_spec) = roof_spec[ 2];
function roof_spec_overhang_span_high( roof_spec) = roof_spec[ 3];
function roof_spec_roof_height_max( roof_spec) = roof_spec[ 4];
function roof_spec_overhang_span_near( roof_spec) = roof_spec[ 5];
function roof_spec_ceiling_span_flat( roof_spec) = roof_spec[ 6];
function roof_spec_overhang_span_far( roof_spec) = roof_spec[ 7];


/* calculate roof slope given ceiling_height_min, overhang_span_low, and
   slope = (roof_height_max - roof_height_min) / ( overhang_span_low + ceiling_span_sloped + overhang_span_high)
   roof_height_min = ceiling_height_min - ( slope * overhang_span_low) + roof_thickness_vertical
   roof_thickness_vertical = roof_thickness * sqrt( slope * slope + 1)

slope * ( overhang_span_low + ceiling_span_sloped + overhang_span_high) = roof_height_max - roof_height_min
slope * ( overhang_span_low + ceiling_span_sloped + overhang_span_high) = roof_height_max - ( ceiling_height_min - ( slope * overhang_span_low) + roof_thickness_vertical)
slope * ( overhang_span_low + ceiling_span_sloped + overhang_span_high) = roof_height_max - ceiling_height_min + ( slope * overhang_span_low) - roof_thickness_vertical
overhang_span_low + ceiling_span_sloped + overhang_span_high = roof_height_max / slope - ceiling_height_min / slope + overhang_span_low - roof_thickness_vertical / slope
ceiling_span_sloped + overhang_span_high = roof_height_max / slope - ceiling_height_min / slope - roof_thickness_vertical / slope
ceiling_span_sloped + overhang_span_high = ( roof_height_max - ceiling_height_min - roof_thickness_vertical) / slope
slope * ( ceiling_span_sloped + overhang_span_high) = roof_height_max - ceiling_height_min - roof_thickness_vertical
slope * ( ceiling_span_sloped + overhang_span_high) = roof_height_max - ceiling_height_min - roof_thickness * sqrt( slope^2 + 1)
span = ceiling_span_sloped + overhang_span_high
delta = roof_height_max - ceiling_height_min
slope * span = delta - roof_thickness * sqrt( slope^2 + 1)
roof_thickness * sqrt( slope^2 + 1) + slope * span = delta
roof_thickness * sqrt( slope^2 + 1) = delta - slope * span
sqrt( slope^2 + 1) = ( delta - slope * span) / roof_thickness
slope^2 + 1 = ( ( delta - slope * span) / roof_thickness)^2
slope^2 + 1 = ( delta - slope * span)^2 / roof_thickness^2
roof_thickness^2 * ( slope^2 + 1) = ( delta - slope * span)^2
roof_thickness^2 * ( slope^2 + 1) = delta^2 - 2 * delta * slope * span + slope^2 * span^2
roof_thickness^2 * slope^2 + roof_thickness^2 = delta^2 - 2 * delta * slope * span + slope^2 * span^2
roof_thickness^2 * slope^2 + (roof_thickness^2 - delta^2) = - 2 * delta * slope * span + slope^2 * span^2
roof_thickness^2 * slope^2 + (2 * delta * span) * slope + (roof_thickness^2 - delta^2) = slope^2 * span^2
roof_thickness^2 * slope^2 - slope^2 * span^2 + (2 * delta * span) * slope + (roof_thickness^2 - delta^2) = 0
( roof_thickness^2 - span^2) * slope^2 + (2 * delta * span) * slope + (roof_thickness^2 - delta^2) = 0
a = roof_thickness^2 - span^2
b = 2 * delta * span
c = roof_thickness^2 - delta^2
slope = ( -b +/- sqrt( b^2 - 4 * a * c)) / ( 2 * a)
*/

function roof_slope( roof_spec, granularity = 12 * 4) = let(
        span = roof_spec_ceiling_span_sloped( roof_spec) + roof_spec_overhang_span_high( roof_spec),
        delta = roof_spec_roof_height_max( roof_spec) - roof_spec_ceiling_height_min( roof_spec),
        a = roof_thickness * roof_thickness - span * span,
        b = 2 * delta * span,
        c = roof_thickness * roof_thickness - delta * delta,
        x = ( -b + sqrt( b * b - 4 * a * c)) / ( 2 * a))
        granularity > 0 ? floor( x * granularity) / granularity : x;

module echo_roof_slope( name, roof_spec) {
//    echo( str( name, " roof spec: ", roof_spec));
    echo( str( name, " roof slope: ", roof_slope( roof_spec) * 12, " / 12"));
//    echo( str( name, " ceiling height min: ", ceiling_height_min( roof_spec), " ft"));
//    echo( str( name, " ceiling height max: ", ceiling_height_max( roof_spec), " ft"));
//    echo( str( name, " roof height max: ", roof_overhang_height_max( roof_spec), " ft"));
//    echo( str( name, " roof height min: ", roof_overhang_height_min( roof_spec), " ft"));
}

function roof_thickness_vertical( roof_spec) = let( slope = roof_slope( roof_spec)) roof_thickness * sqrt( slope * slope + 1);

function roof_overhang_span_low( roof_spec) = roof_spec_overhang_span_low( roof_spec);
function ceiling_span_sloped( roof_spec) = roof_spec_ceiling_span_sloped( roof_spec);
function roof_overhang_span_high( roof_spec) = roof_spec_overhang_span_high( roof_spec);
function roof_total_span_sloped( roof_spec) =
        roof_overhang_span_low( roof_spec) + ceiling_span_sloped( roof_spec) + roof_overhang_span_high( roof_spec);

function roof_overhang_height_max( roof_spec) = roof_spec_roof_height_max( roof_spec);
function roof_overhang_height_min( roof_spec) = roof_overhang_height_max( roof_spec) - roof_slope( roof_spec) * roof_total_span_sloped( roof_spec);
function ceiling_height_min( roof_spec, wall_offset = 0) = roof_overhang_height_max( roof_spec) - roof_thickness_vertical( roof_spec) - roof_slope( roof_spec) * ( roof_total_span_sloped( roof_spec) - roof_overhang_span_low( roof_spec) - wall_offset);
function ceiling_height_max( roof_spec, wall_offset = 0) = roof_overhang_height_max( roof_spec) - roof_thickness_vertical( roof_spec) - roof_slope( roof_spec) * ( roof_overhang_span_high( roof_spec) + wall_offset);

function roof_overhang_span_near( roof_spec) = roof_spec_overhang_span_near( roof_spec);
function ceiling_span_flat( roof_spec) = roof_spec_ceiling_span_flat( roof_spec);
function roof_overhang_span_far( roof_spec) = roof_spec_overhang_span_far( roof_spec);

function roof_total_span_flat( roof_spec) =
        roof_overhang_span_near( roof_spec) + ceiling_span_flat( roof_spec) + roof_overhang_span_far( roof_spec);

module make_roof( roof_spec) {
    width = roof_total_span_sloped( roof_spec);
    length = roof_total_span_flat( roof_spec);
    height_min = roof_overhang_height_min( roof_spec);
    height_max = roof_overhang_height_max( roof_spec);
    thickness_vertical = roof_thickness_vertical( roof_spec);
    overhang_span_low = roof_overhang_span_low( roof_spec);
    overhang_span_near = roof_overhang_span_near( roof_spec);
    translate( [ -overhang_span_low, length - overhang_span_near, 0]) {
        rotate( [ 90, 0, 0]) {
            linear_extrude( length) {
                polygon( [ [ width, height_max],
                           [ width, height_max - thickness_vertical],
                           [ 0, height_min - thickness_vertical],
                           [ 0, height_min]]);
            }
        }
    }
}

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

/* Garage */

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

/* Connector */

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

/* Mainhouse */

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

/* Entrance */

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

/* Whole house */

module ground() {
    translate( [ -50 * ft, -100 * ft - connector_width, -1 * in]) cube( [ 200 * ft, 100 * ft, 1 * in]);
    grade_angle = atan( basement_depth / mainhouse_width);
    translate( [ -50 * ft, -connector_width, -1 * in])
            rotate( [ -grade_angle, 0, 0])
            cube( [ 200 * ft, sqrt( mainhouse_width * mainhouse_width + basement_depth * basement_depth) + 50 * ft, 1 * in]);
}

module envelope( wall_offset = 0, extra_height = 0, extra_depth = 0) {
    union() {
        garage_envelope( wall_offset, extra_height, extra_depth)
        connector_envelope( wall_offset, extra_height, extra_depth)
        mainhouse_envelope( wall_offset, extra_height, extra_depth);
    }
}

module roof() {
    garage_roof()
    connector_roof() {
        mainhouse_roof();
        entrance_roof();
    }
}

module exterior_walls() {
    difference() {
        envelope();
        envelope( exterior_wall_thickness, extra_height = 1 * in, extra_depth = 1 * in);
    }
}

module house() {
    %ground();
    exterior_walls();
    %roof();
}

module upper_floor_plan() {
    projection( cut=true) {
        translate( [ 0, 0, -1]) {
            house();
        }
    }
}

module lower_floor_plan() {
    projection( cut=true) {
        translate( [ 0, 0, basement_depth - 1]) {
            house();
        }
    }
}

module floor_plans() {
    border = 10 * ft;
    translate( [ border, border, 0]) {
        translate( [ 0, connector_width + mainhouse_width + border, 0]) {
            upper_floor_plan();
        }
        translate( [ 0, connector_width, 0]) {
            lower_floor_plan();
        }
    }
}

//house();
//floor_plans();
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
