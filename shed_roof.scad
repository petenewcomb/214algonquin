/*
  Note page 19 of:
  http://energy.gov/sites/prod/files/2015/02/f19/ba_webinar_2-12-15_lstiburek.pdf
*/

$default_slope_denominator = 12;
$default_slope_granularity = 4 * $default_slope_denominator;

/* Specification */
function shed_roof_spec(
        sloped_span,
        flat_span,
        min_roof_height,
        max_roof_height,
        vertical_thickness)
    = [ sloped_span,
        flat_span,
        min_height,
        max_height,
        vertical_thickness];

function shed_roof_sloped_span( spec) = spec[ 0];
function shed_roof_flat_span( spec) = spec[ 1];
function shed_roof_min_roof_height( spec) = spec[ 2];
function shed_roof_max_roof_height( spec) = spec[ 3];
function shed_roof_vertical_thickness( spec) = spec[ 4];

/*

  Calculate roof slope given span, min_ceiling_height, max_roof_height, thickness, and ceiling_start_offset:

        slope = ( max_roof_height - min_roof_height) / span
        min_roof_height = min_ceiling_height - ( slope * ceiling_start_offset) + vertical_thickness
        vertical_thickness = thickness * sqrt( slope * slope + 1)

  solve for slope:

        slope * span = max_roof_height - min_roof_height
        slope * span = max_roof_height - ( min_ceiling_height - ( slope * ceiling_start_offset) + vertical_thickness)
        slope * span = max_roof_height - min_ceiling_height + ( slope * ceiling_start_offset) - vertical_thickness
        span = max_roof_height / slope - min_ceiling_height / slope + ceiling_start_offset - vertical_thickness / slope
        span - ceiling_start_offset = max_roof_height / slope - min_ceiling_height / slope - vertical_thickness / slope
        span - ceiling_start_offset = ( max_roof_height - min_ceiling_height - vertical_thickness) / slope
        slope * ( span - ceiling_start_offset) = max_roof_height - min_ceiling_height - vertical_thickness
        slope * ( span - ceiling_start_offset) = max_roof_height - min_ceiling_height - thickness * sqrt( slope^2 + 1)
        delta = max_roof_height - min_ceiling_height
        slope * span = delta - thickness * sqrt( slope^2 + 1)
        thickness * sqrt( slope^2 + 1) + slope * span = delta
        thickness * sqrt( slope^2 + 1) = delta - slope * span
        sqrt( slope^2 + 1) = ( delta - slope * span) / thickness
        slope^2 + 1 = ( ( delta - slope * span) / thickness)^2
        slope^2 + 1 = ( delta - slope * span)^2 / thickness^2
        thickness^2 * ( slope^2 + 1) = ( delta - slope * span)^2
        thickness^2 * ( slope^2 + 1) = delta^2 - 2 * delta * slope * span + slope^2 * span^2
        thickness^2 * slope^2 + thickness^2 = delta^2 - 2 * delta * slope * span + slope^2 * span^2
        thickness^2 * slope^2 + (thickness^2 - delta^2) = - 2 * delta * slope * span + slope^2 * span^2
        thickness^2 * slope^2 + (2 * delta * span) * slope + (thickness^2 - delta^2) = slope^2 * span^2
        thickness^2 * slope^2 - slope^2 * span^2 + (2 * delta * span) * slope + (thickness^2 - delta^2) = 0
        ( thickness^2 - span^2) * slope^2 + (2 * delta * span) * slope + (thickness^2 - delta^2) = 0
        a = thickness^2 - span^2
        b = 2 * delta * span
        c = thickness^2 - delta^2
        slope = ( -b +/- sqrt( b^2 - 4 * a * c)) / ( 2 * a)

*/
function shed_roof_slope_from_constraints(
        span,
        min_ceiling_height,
        max_roof_height,
        thickness,
        granularity = $default_slope_granularity)
    = let( delta = max_roof_height - min_ceiling_height,
           a = thickness * thickness - span * span,
           b = 2 * delta * span,
           c = thickness * thickness - delta * delta,
           x = ( -b + sqrt( b * b - 4 * a * c)) / ( 2 * a))
        granularity > 0 ? floor( x * granularity) / granularity : x;

function shed_roof_vertical_thickness_from_slope( thickness, slope)
    = let( slope = roof_slope( roof_spec))
        roof_thickness * sqrt( slope * slope + 1);

function shed_roof_spec_from_constraints(
        sloped_span,
        flat_span,
        min_ceiling_height,
        max_roof_height,
        thickness,
        ceiling_start_offset = 0,
        granularity = $default_slope_granularity)
    = let( slope = shed_roof_slope_from_constraints(
                       span = sloped_span - ceiling_start_offset,
                       min_ceiling_height = min_ceiling_height,
                       max_roof_height = max_roof_height,
                       thickness = thickness,
                       granularity = granularity))
    = shed_roof_spec(
          sloped_span = sloped_span,
          flat_span = flat_span,
          min_height = max_roof_height - slope * sloped_span;
          max_height = max_roof_height,
          vertical_thickness = shed_roof_vertical_thickness_from_slope(
                                   thickness = thickness,
                                   slope = slope));

module echo_shed_roof_slope( name, spec, denominator = $default_slope_denominator) {
    echo( str( name, " roof slope: ", shed_roof_slope( spec) * denominator, " / ", denominator));
}

module shed_roof( spec) {
    sloped_span = shed_roof_sloped_span( spec);
    flat_span = shed_roof_flat_span( spec);
    height_min = shed_roof_height_min( spec);
    height_max = shed_roof_height_max( spec);
    vertical_thickness = shed_roof_vertical_thickness( spec);
    rotate( [ 90, 0, 0]) {
        linear_extrude( flat_span) {
            polygon( [ [ 0, height_min],
                       [ sloped_span, height_max],
                       [ sloped_span, height_max - vertical_thickness],
                       [ 0, height_min - vertical_thickness]]);
        }
    }
}