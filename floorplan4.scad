include <units.scad>;
include <lot.scad>;
include <building_area.scad>;
include <MCAD/2Dshapes.scad>;

default_font = "Comic Sans MS:style=Regular";

exterior_wall_thickness = 5.5 * in + 1.5 * in + 0.5 * in;
interior_wall_thickness = 3.5 * in + 0.5 * in + 0.5 * in;

/* South garage */

south_garage_x = 24 * ft;
south_garage_y = 24 * ft;
module position_south_garage() {
    position_building_area() {
        translate( [ 2 * exterior_wall_thickness + north_garage_x, exterior_wall_thickness + -( exterior_wall_thickness + north_garage_x) * sin( northwest_boundary_angle - southwest_boundary_angle - 90)]) {
            children();
        }
    }
}
module south_garage() {
    position_south_garage() {
        square( [ south_garage_x, south_garage_y]);
    }
}

/* North garage */

north_garage_x = 24 * ft;
north_garage_y = 24 * ft;
module position_north_garage() {
    position_south_garage() {
        translate( [ -exterior_wall_thickness - south_garage_x, exterior_wall_thickness + south_garage_y]) {
            children();
        }
    }
}
module north_garage() {
    position_north_garage() {
        square( [ north_garage_x, north_garage_y]);
    }
}



/* Floorplan */

module upperfloor_rooms() {
    north_garage();
    south_garage();
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


upperfloor_walls_2d();

%building_area_lines();
%lot_lines();
%rock();
%bigtree();
%meter();

