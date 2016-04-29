include <lot.scad>;

/*
    y = p1[ 1] + ( x - p1[ 0]) * v1[ 1] / v1[ 0]
    y = p1[ 1] + ( x * v1[ 1] - p1[ 0] * v1[ 1]) / v1[ 0]
    y = p1[ 1] + x * v1[ 1] / v1[ 0] - p1[ 0] * v1[ 1] / v1[ 0]
    y = x * v1[ 1] / v1[ 0] + ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0])

    y = x * v1[ 1] / v1[ 0] + ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0])
    y = x * v2[ 1] / v2[ 0] + ( p2[ 1] - p2[ 0] * v2[ 1] / v2[ 0])

    x * v1[ 1] / v1[ 0] + ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0]) = x * v2[ 1] / v2[ 0] + ( p2[ 1] - p2[ 0] * v2[ 1] / v2[ 0])
    x * v1[ 1] / v1[ 0] - x * v2[ 1] / v2[ 0] = ( p2[ 1] - p2[ 0] * v2[ 1] / v2[ 0]) - ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0])
    x * v1[ 1] / v1[ 0] - x * v2[ 1] / v2[ 0] = ( p2[ 1] - p2[ 0] * v2[ 1] / v2[ 0]) - ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0])

    x * ( v1[ 1] / v1[ 0] - v2[ 1] / v2[ 0]) = ( p2[ 1] - p2[ 0] * v2[ 1] / v2[ 0]) - ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0])
    x = ( ( p2[ 1] - p2[ 0] * v2[ 1] / v2[ 0]) - ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0])) / ( v1[ 1] / v1[ 0] - v2[ 1] / v2[ 0])
*/

function line_intersection( p1, v1, p2, v2) =
        let( x = ( ( p2[ 1] - p2[ 0] * v2[ 1] / v2[ 0]) - ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0])) / ( v1[ 1] / v1[ 0] - v2[ 1] / v2[ 0]),
             y = x * v1[ 1] / v1[ 0] + ( p1[ 1] - p1[ 0] * v1[ 1] / v1[ 0]))
        [ x, y];


building_area_southwest_setback_vector = vector_from_polar( southwest_boundary_angle + 90, 50 * ft);
building_area_northwest_setback_vector = vector_from_polar( northwest_boundary_angle - 90, 20 * ft);
building_area_southeast_setback_vector = vector_from_polar( southeast_boundary_angle + 90, 20 * ft);

building_area_west_corner = line_intersection(
        p1 = vector_sum( [ west_corner, building_area_northwest_setback_vector]),
        v1 = vector_difference( north_corner, west_corner),
        p2 = vector_sum( [ west_corner, building_area_southwest_setback_vector]),
        v2 = vector_difference( south_corner, west_corner));

building_area_south_corner = line_intersection(
        p1 = vector_sum( [ south_corner, building_area_southeast_setback_vector]),
        v1 = vector_difference( east_corner, south_corner),
        p2 = vector_sum( [ south_corner, building_area_southwest_setback_vector]),
        v2 = vector_difference( west_corner, south_corner));

setback_from_abrupt_change_in_slope = 20 * ft;

building_area_north_corner = vector_sum( [ building_area_west_corner, vector_from_polar( northwest_boundary_angle, 100 * ft - setback_from_abrupt_change_in_slope)]);
building_area_northeast_corner = vector_sum( [ building_area_south_corner, vector_from_polar( southwest_boundary_angle + 180, 25 * ft), vector_from_polar( southeast_boundary_angle, 80 * ft - setback_from_abrupt_change_in_slope)]);
building_area_east_corner = vector_sum( [ building_area_south_corner, vector_from_polar( southeast_boundary_angle, 65 * ft - setback_from_abrupt_change_in_slope)]);

building_area_polygon = [
        building_area_west_corner,
        building_area_north_corner,
        building_area_northeast_corner,
        building_area_east_corner,
        building_area_south_corner
//        vector_sum( [ west_corner, vector_from_polar( northwest_boundary_angle, 0 * ft), vector_from_polar( northwest_boundary_angle - 90, 20 * ft)]),
//        vector_sum( [ south_corner, vector_from_polar( southeast_boundary_angle, 50 * ft), vector_from_polar( southwest_boundary_angle, -20 * ft)]),
//        vector_sum( [ south_corner, vector_from_polar( southeast_boundary_angle, 90 * ft), vector_from_polar( southwest_boundary_angle, -20 * ft)]),
//        vector_sum( [ south_corner, vector_from_polar( southeast_boundary_angle, 110 * ft), vector_from_polar( southwest_boundary_angle, -50 * ft)]),
//        vector_sum( [ west_corner, vector_from_polar( northwest_boundary_angle, 130 * ft), vector_from_polar( southwest_boundary_angle, 20 * ft)])
];

module building_area_2d() {
    polygon( building_area_polygon);
}
