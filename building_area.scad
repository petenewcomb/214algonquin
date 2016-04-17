include <lot.scad>;

building_area_polygon = [
        vector_sum( [ west_corner, vector_from_polar( northwest_boundary_angle, 50 * ft), vector_from_polar( southwest_boundary_angle, 20 * ft)]),
        vector_sum( [ south_corner, vector_from_polar( southeast_boundary_angle, 50 * ft), vector_from_polar( southwest_boundary_angle, -20 * ft)]),
        vector_sum( [ south_corner, vector_from_polar( southeast_boundary_angle, 90 * ft), vector_from_polar( southwest_boundary_angle, -20 * ft)]),
        vector_sum( [ south_corner, vector_from_polar( southeast_boundary_angle, 110 * ft), vector_from_polar( southwest_boundary_angle, -50 * ft)]),
        vector_sum( [ west_corner, vector_from_polar( northwest_boundary_angle, 130 * ft), vector_from_polar( southwest_boundary_angle, 20 * ft)])
];

echo( building_area_polygon);
echo( [ west_corner, vector_from_polar( northwest_boundary_angle, 50 * ft), vector_from_polar( southwest_boundary_angle, 20 * ft)]);

module building_area_2d() {
    polygon( building_area_polygon);
}
