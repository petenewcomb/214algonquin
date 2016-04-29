include <units.scad>;
include <lot.scad>;
include <building_area.scad>;
include <MCAD/2Dshapes.scad>;

default_font = "Comic Sans MS:style=Regular";

exterior_wall_thickness = 5.5 * in + 1.5 * in + 0.5 * in;
interior_wall_thickness = 3.5 * in + 0.5 * in + 0.5 * in;

/* Dining area */

diningarea_x = 12 * ft;
diningarea_y = 10 * ft;
module position_diningarea() {
    position_greatroom() {
        translate( [ greatroom_x - diningarea_x, greatroom_y - diningarea_y]) {
            children();
        }
    }
}

/* Kitchen */

kitchen_walkway_width = 36 * in;
counter_depth = 25.5 * in;
counter_overhang = 1 * in;

dishwasher_depth = counter_depth - counter_overhang;
dishwasher_width = 24 * in;
module dishwasher() {
    translate( [ 0, counter_overhang]) {
        difference() {
            square( [ dishwasher_width, dishwasher_depth]);
            translate( [ dishwasher_width / 2, dishwasher_depth / 2]) {
                text( "DW", size = dishwasher_depth / 5, halign = "center", valign = "center", font = default_font);
            }
        }
    }
}

// http://www.ajmadison.com/cgi-bin/ajmadison/CIT36XKBB.html
cooktop_depth = counter_depth - counter_overhang;
cooktop_width = 36 * in;
module cooktop() {
    translate( [ 0, counter_overhang]) {
        difference() {
            square( [ cooktop_width, cooktop_depth]);
            translate( [ cooktop_width / 2, cooktop_depth / 2]) {
                text( "COOKTOP", size = cooktop_depth / 5, halign = "center", valign = "center", font = default_font);
            }
        }
    }
}

// http://www.ajmadison.com/cgi-bin/ajmadison/CIT36XKBB.html
kitchen_sink_depth = counter_depth - counter_overhang;
kitchen_sink_width = 36 * in;
module kitchen_sink() {
    translate( [ 2 * in, counter_overhang]) {
        difference() {
            square( [ kitchen_sink_width - 4 * in, kitchen_sink_depth - 4 * in]);
            translate( [ kitchen_sink_width / 2 - 2 * in, kitchen_sink_depth / 2 - 2 * in]) {
                text( "SINK", size = kitchen_sink_depth / 5, halign = "center", valign = "center", font = default_font);
            }
        }
    }
}

// http://www.ajmadison.com/cgi-bin/ajmadison/MEDMCW31JS.html
oven_depth = counter_depth - counter_overhang;
oven_width = 30 * in;
module oven() {
    translate( [ 0, counter_overhang]) {
        difference() {
            square( [ oven_width, oven_depth]);
            translate( [ oven_width / 2, oven_depth / 2]) {
                text( "OVEN", size = oven_depth / 5, halign = "center", valign = "center", font = default_font);
            }
        }
    }
}

refrigerator_depth = counter_depth + 3 * in;
refrigerator_width = 30 * in;
module refrigerator() {
    translate( [ 0, counter_overhang]) {
        difference() {
            square( [ refrigerator_width, refrigerator_depth]);
            translate( [ 1 * in, 1 * in]) {
                square( [ refrigerator_width - 2 * in, refrigerator_depth - 2 * in]);
            }
        }
        translate( [ refrigerator_width / 2, refrigerator_depth / 2]) {
            text( "REF.", size = refrigerator_depth / 5, halign = "center", valign = "center", font = default_font);
        }
    }
}

kitchen_island_x = 6 * ft;
kitchen_island_y = 60 * in;
module position_kitchen_island() {
    position_kitchen() {
        translate( [ ( kitchen_x - kitchen_sidewall_x - kitchen_island_x) / 2, kitchen_backwall_y + kitchen_walkway_width]) {
            children();
        }
    }
}
module kitchen_island() {
    position_kitchen_island() {
        difference() {
            square( [ kitchen_island_x, kitchen_island_y]);
        }
    }
}

kitchen_peninsula_x = counter_overhang + dishwasher_width + kitchen_sink_width + 1 * ft + counter_depth;
kitchen_peninsula_y = counter_depth + interior_wall_thickness + 12 * in;
module position_kitchen_peninsula() {
    position_kitchen() {
        translate( [ kitchen_x - kitchen_peninsula_x, kitchen_y - kitchen_peninsula_y]) {
            children();
        }
    }
}
module kitchen_peninsula() {
    position_kitchen_peninsula() {
        difference() {
            square( [ kitchen_peninsula_x, kitchen_peninsula_y]);
            translate( [ counter_overhang, 0]) {
                dishwasher();
                translate( [ dishwasher_width, 0]) {
                    kitchen_sink();
                }
            }
        }
    }
}

kitchen_backwall_x = refrigerator_width + 1 * ft + oven_width + 1 * ft + counter_depth;
kitchen_backwall_y = counter_depth;
module position_kitchen_backwall() {
    position_kitchen() {
        translate( [ kitchen_x - kitchen_backwall_x, 0]) {
            children();
        }
    }
}
module kitchen_backwall() {
    position_kitchen_backwall() {
        difference() {
            translate( [ refrigerator_width, 0]) {
                square( [ kitchen_backwall_x - refrigerator_width, kitchen_backwall_y]);
            }
            translate( [ refrigerator_width + 1 * ft, 0]) {
                translate( [ oven_width, oven_depth]) {
                    rotate( [ 0, 0, -180]) {
                        oven();
                    }
                }
            }
        }
        translate( [ refrigerator_width, refrigerator_depth]) {
            rotate( [ 0, 0, -180]) {
                refrigerator();
            }
        }
    }
}

kitchen_y = kitchen_peninsula_y + 2 * kitchen_walkway_width + kitchen_island_y + kitchen_backwall_y;

kitchen_sidewall_x = counter_depth;
kitchen_sidewall_y = kitchen_y - kitchen_peninsula_y - kitchen_backwall_y;
module position_kitchen_sidewall() {
    position_kitchen() {
        translate( [ kitchen_x - kitchen_sidewall_x, kitchen_backwall_y]) {
            children();
        }
    }
}
module kitchen_sidewall() {
    position_kitchen_sidewall() {
        difference() {
            translate( [ 0, -1 * in]) {
                square( [ kitchen_sidewall_x, kitchen_sidewall_y + 2 * in]);
            }
            translate( [ 0, kitchen_sidewall_y - cooktop_width - 1 * ft]) {
                translate( [ 0, cooktop_width]) {
                    rotate( [ 0, 0, -90]) {
                        cooktop();
                    }
                }
            }
        }
    }
}

kitchen_x = 3 * kitchen_walkway_width + kitchen_island_x + kitchen_sidewall_x;
module position_kitchen() {
    position_diningarea() {
        translate( [ diningarea_x - kitchen_x, -interior_wall_thickness - kitchen_y]) {
            children();
        }
    }
}
module kitchen_fixtures() {
    kitchen_peninsula();
    kitchen_sidewall();
    kitchen_backwall();
    kitchen_island();
}

/* Pantry */

pantry_x = 48 * in;
pantry_y = counter_depth - interior_wall_thickness;
module position_pantry() {
    position_kitchen_backwall() {
        translate( [ -pantry_x - interior_wall_thickness, 0]) {
            children();
        }
    }
}
module pantry() {
    position_pantry() {
        square( [ pantry_x, pantry_y]);
    }
}

/* Northwest Garage */

northwest_garage_x = 24 * ft;
northwest_garage_y = 24 * ft;
module position_northwest_garage() {
    position_building() {
        translate( [ exterior_wall_thickness, exterior_wall_thickness]) {
            children();
        }
    }
}
module northwest_garage() {
    position_northwest_garage() {
        square( [ northwest_garage_x, northwest_garage_y]);
    }
}

/* Workshop */

workshop_x = 12 * ft;
workshop_y = 20 * ft;
module position_workshop() {
    position_northwest_garage() {
        translate( [ 0, northwest_garage_y + exterior_wall_thickness]) {
            children();
        }
    }
}
module workshop() {
    position_workshop() {
        square( [ workshop_x, workshop_y]);
    }
}


/* Northwest_connector */

northwest_connector_x = 8 * ft;
northwest_connector_y = northwest_garage_y + exterior_wall_thickness + 3 * ft;
northwest_connector_west_corner = [ 0, 0];
northwest_connector_north_corner = [ 0, northwest_connector_y];
northwest_connector_east_corner = [ northwest_connector_x, northwest_connector_y];
northwest_connector_south_corner = [ northwest_connector_x, 0];
module position_northwest_connector() {
    position_northwest_garage() {
        translate( [ northwest_garage_x + exterior_wall_thickness, 0]) {
            children();
        }
    }
}
module northwest_connector() {
    position_northwest_connector() {
        polygon( [ northwest_connector_west_corner,
                   northwest_connector_north_corner,
                   northwest_connector_east_corner,
                   northwest_connector_south_corner]);
    }
}

/* Mudroom */

northwest_garage_angle = northwest_boundary_angle - ( southwest_boundary_angle + 90);

mudroom_x = 20 * ft;
//mudroom_y = northwest_garage_y * cos( northwest_garage_angle);
mudroom_y = 8 * ft;
mudroom_west_corner = [ 0, 0];
mudroom_north_corner = [ -mudroom_y * sin( northwest_garage_angle), mudroom_y];
mudroom_east_corner = [ mudroom_x + mudroom_y * sin( northwest_garage_angle), mudroom_y];
mudroom_south_corner = [ mudroom_x, 0];
module position_mudroom() {
    position_northwest_connector() {
        translate( [ northwest_connector_x + interior_wall_thickness, 0]) {
            rotate( [ 0, 0, -northwest_garage_angle]) {
                children();
            }
        }
    }
}
module mudroom() {
    position_mudroom() {
        polygon( [ mudroom_west_corner,
                   mudroom_north_corner,
                   mudroom_east_corner,
                   mudroom_south_corner]);
    }
}

/* Southeast_connector */

southeast_connector_x = northwest_connector_x;
southeast_connector_y = northwest_connector_y;
southeast_connector_west_corner = [ 0, 0];
southeast_connector_north_corner = [ 0, southeast_connector_y];
southeast_connector_east_corner = [ southeast_connector_x, southeast_connector_y];
southeast_connector_south_corner = [ southeast_connector_x, 0];
module position_southeast_connector() {
    position_mudroom() {
        translate( [ mudroom_x, 0]) {
            rotate( [ 0, 0, -northwest_garage_angle]) {
                translate( [ interior_wall_thickness, 0]) {
                    children();
                }
            }
        }
    }
}
module southeast_connector() {
    position_southeast_connector() {
        polygon( [ southeast_connector_west_corner,
                   southeast_connector_north_corner,
                   southeast_connector_east_corner,
                   southeast_connector_south_corner]);
    }
}

/* Southeast Garage */

southeast_garage_x = 24 * ft;
southeast_garage_y = 24 * ft;
module position_southeast_garage() {
    position_southeast_connector() {
        translate( [ southeast_connector_x + exterior_wall_thickness, 0]) {
            children();
        }
    }
}
module southeast_garage() {
    position_southeast_garage() {
        square( [ southeast_garage_x, southeast_garage_y]);
    }
}

/* Stairs */

// TODO: figure out stairs to loft, too, including landing (turn?)
stairs_x = 16 * ft; // TODO: calculate from pitch and basement depth
stairs_y = 3 * ft;
module position_stairs() {
    position_greatroom() {
        translate( [ ( greatroom_x - stairs_x) / 2, 0]) {
            children();
        }
    }
}
module stairs() {
    position_stairs() {
        #square( [ stairs_x + 1 * in, stairs_y]);
    }
}

/* Greatroom */

greatroom_x = mudroom_x + 2 * ( mudroom_y + interior_wall_thickness) * sin( northwest_garage_angle);
greatroom_y = stairs_y + diningarea_y + interior_wall_thickness + kitchen_y;

echo( str( "garage angle: ", northwest_garage_angle));

greatroom_west_corner = [ 0, 0];
greatroom_north_corner = [ -greatroom_y * sin( northwest_garage_angle), greatroom_y];
greatroom_northeast_corner = [ greatroom_x / 2, greatroom_y + 6 * ft];
greatroom_east_corner = [ greatroom_x + greatroom_y * sin( northwest_garage_angle), greatroom_y];
greatroom_south_corner = [ greatroom_x, 0];

module position_greatroom() {
    position_mudroom() {
        translate( vector_from_polar( 90 + northwest_garage_angle, interior_wall_thickness)) {
            translate( mudroom_north_corner) {
                children();
            }
        }
    }
}
module greatroom() {
        position_greatroom() {
            polygon( [ greatroom_west_corner,
                       greatroom_north_corner,
                       greatroom_northeast_corner,
                       greatroom_east_corner,
                       greatroom_south_corner]);
        }
/*
    difference() {
        position_greatroom() {
            square( [ greatroom_x, greatroom_y]);
        }
        position_mudroom() {
            translate( [ 0, -1 * in]) {
                square( [ mudroom_x + interior_wall_thickness, mudroom_y + interior_wall_thickness + 1 * in]);
            }
        }
        position_pantry() {
            translate( [ -interior_wall_thickness, -1 * in]) {
                square( [ pantry_x + 2 * interior_wall_thickness, pantry_y + interior_wall_thickness + 1 * in]);
            }
        }
    }
*/
}

/* Laundry room */

laundryroom_x = northwest_garage_x - mudroom_x - interior_wall_thickness;
laundryroom_y = mudroom_y;
module position_laundryroom() {
    position_mudroom() {
        translate( [ -laundryroom_x - interior_wall_thickness, 0]) {
            children();
        }
    }
}
module laundryroom() {
    position_laundryroom() {
        square( [ laundryroom_x, laundryroom_y]);
    }
}


/* Entrance */

entrance_x = 5 * ft;
entrance_y = stairs_y + interior_wall_thickness;
module position_entrance() {
    position_greatroom() {
        translate( [ -entrance_x, 0]) {
            children();
        }
    }
}
module entrance() {
    position_entrance() {
        square( [ entrance_x + 1 * in, entrance_y + 1 * in]);
    }
}

/* Hallway */

hallway_x = stairs_x + entrance_x;
hallway_y = 3 * ft;
module position_hallway() {
    position_greatroom() {
        translate( [ -hallway_x, entrance_y]) {
            children();
        }
    }
}
module hallway() {
    position_hallway() {
        square( [ hallway_x + 1 * in, hallway_y]);
    }
}


second_bedroom_x = 12 * ft;
second_bedroom_y = 11 * ft;
module position_second_bedroom() {
    position_hallway() {
        translate( [ hallway_x - second_bedroom_x - interior_wall_thickness, hallway_y + interior_wall_thickness]) {
            children();
        }
    }
}
module second_bedroom() {
    position_second_bedroom() {
        square( [ second_bedroom_x, second_bedroom_y]);
    }
}

second_bathroom_x = 10 * ft;
second_bathroom_y = 6 * ft;
module position_second_bathroom() {
    position_second_bedroom() {
        translate( [ -second_bathroom_x + -interior_wall_thickness, 0]) {
            children();
        }
    }
}
module second_bathroom() {
    position_second_bathroom() {
        square( [ second_bathroom_x, second_bathroom_y]);
    }
}




master_bathroom_x = 12 * ft;
master_bathroom_y = 8 * ft;
module position_master_bathroom() {
    position_greatroom() {
        translate( [ greatroom_x + interior_wall_thickness, greatroom_y - master_bathroom_y]) {
            children();
        }
    }
}
module master_bathroom() {
    position_master_bathroom() {
        square( [ master_bathroom_x, master_bathroom_y]);
    }
}

master_bedroom_x = 12 * ft;
master_bedroom_y = 15 * ft;
module position_master_bedroom() {
    position_master_bathroom() {
        translate( [ master_bathroom_x + interior_wall_thickness, master_bathroom_y - master_bedroom_y]) {
            children();
        }
    }
}
module master_bedroom() {
    position_master_bedroom() {
        square( [ master_bedroom_x, master_bedroom_y]);
    }
}

master_closet_x = master_bathroom_x;
master_closet_y = master_bedroom_y - master_bathroom_y - interior_wall_thickness;
module position_master_closet() {
    position_master_bedroom() {
        translate( [ -master_closet_x - interior_wall_thickness, 0]) {
            children();
        }
    }
}
module master_closet() {
    position_master_closet() {
        square( [ master_closet_x, master_closet_y]);
    }
}

module rooms() {
    greatroom();
//    pantry();
//    laundryroom();
    mudroom();
    northwest_garage();
    northwest_connector();
    workshop();

    southeast_garage();
    southeast_connector();


//    hallway();
    stairs();
//    entrance();

//    second_bedroom();
//    second_bathroom();

//    master_bedroom();
//    master_bathroom();
//    master_closet();

}

echo( str( "gross sqft =", (
 greatroom_x * ( greatroom_y + mudroom_y)
 + hallway_x * ( entrance_y + hallway_y + second_bedroom_y)
 )));

module upperfloor_fixtures() {
//    kitchen_fixtures();
}

module upperfloor_walls_2d() {
    difference() {
        internal_offset_thickness = max( interior_wall_thickness, exterior_wall_thickness) + 1;
        offset( delta = exterior_wall_thickness - internal_offset_thickness) {
            offset( delta = internal_offset_thickness) {
                rooms();
            }
        }
        rooms();
    }
}

/* Lot boundaries */
module position_lot_lines() {
//    translate( [ view_x + 20 * ft, -southeast_boundary_length / 2 + 20 * ft]) {
//        rotate( [ 0, 0, -southwest_boundary_angle]) {
//            translate( vector_difference( west_corner, south_corner)) {
                children();
//            }
//        }
//    }
}
module lot_lines() {
    position_lot_lines() {
        %difference() {
            offset( delta = interior_wall_thickness) lot_2d();
            lot_2d();
        }
        %difference() {
            offset( delta = interior_wall_thickness) building_area_2d();
            building_area_2d();
        }
    }
}

module position_building() {
    position_lot_lines() {
        translate( building_area_west_corner) {
            rotate( [ 0, 0, northwest_boundary_angle - 90]) {
                children();
            }
        }
    }
}

/* Big rock next to driveway */
module position_rock() {
    position_lot_lines() {
        rotate( [ 0, 0, southwest_boundary_angle]) {
            translate( [ 35 * ft, 65 * ft]) {
                children();
            }
        }
    }
}
module rock() {
    position_rock() {
        %circle( r = 5 * ft);
    }
}

/* Big tree next to driveway */
module position_bigtree() {
    position_lot_lines() {
        rotate( [ 0, 0, southwest_boundary_angle]) {
            translate( [ 65 * ft, 45 * ft]) {
                children();
            }
        }
    }
}
module bigtree() {
    position_bigtree() {
        %circle( r = 5 * ft);
    }
}

/* Electrical meter */
module position_meter() {
    position_lot_lines() {
        rotate( [ 0, 0, southwest_boundary_angle]) {
            translate( [ southwest_boundary_length - 30 * ft, 31 * ft]) {
                children();
            }
        }
    }
}
module meter() {
    position_meter() {
        rotate( [ 0, 0, 45]) {
            %square( [ 5 * ft, 1 * ft]);
        }
    }
}

/* Driveway circle */
drivewaycircle_outer_diameter = 70 * ft;
drivewaycircle_inner_diameter = 30 * ft;
module position_drivewaycircle() {
    position_lot_lines() {
        rotate( [ 0, 0, northwest_boundary_angle - 90]) {
            translate( [ drivewaycircle_outer_diameter / 2 + 5 * ft, 65 * ft]) {
                children();
            }
        }
    }
}
module drivewaycircle() {
    position_drivewaycircle() {
        difference() {
            circle( d = drivewaycircle_outer_diameter);
            circle( d = drivewaycircle_inner_diameter);
        }
    }
}


driveway_setback = 6 * ft;

driveway_width = 12 * ft;
driveway_entrance_flare_radius = 10 * ft;


module driveway_entrance( angle) {
    positive_flare_offset = driveway_entrance_flare_radius / tan( ( angle + 90) / 2);
    negative_flare_offset = driveway_entrance_flare_radius / tan( ( 90 - angle) / 2);
    max_flare_offset = max( positive_flare_offset, negative_flare_offset);
    driveway_x = driveway_width * tan( angle);

    driveway_polygon = polygon_from_path( [ [ 0, 0],
            vector_from_polar( angle, negative_flare_offset),
            [ -driveway_x, 0],
            vector_from_polar( 180 - angle, positive_flare_offset)]);
    echo(driveway_polygon);

    difference() {
        union() {
            translate( [ -driveway_x / 2, 0, 0]) {
                polygon( driveway_polygon);
            }
        }
/*
            hull() {
                #circle( d = driveway_width);
                rotate( [ 0, 0, angle]) {
                    translate( [ max( positive_flare_offset, negative_flare_offset), 0]) {
                        circle( d = driveway_width);
                    }
                }
            }
            translate( [ driveway_width / 2 + positive_flare_offset, driveway_entrance_flare_radius]) {
                %circle( r = driveway_entrance_flare_radius);
            }
            translate( [ -driveway_width / 2 - negative_flare_offset, driveway_entrance_flare_radius]) {
                %circle( r = driveway_entrance_flare_radius);
            }
*/
        }
/*
//        polygon( [ [ negative_flare_offset - driveway_width / 2, -driveway_width / 2 + 1 * in],
//                   [ negative_flare_offset - driveway_width / 2, 0],
//                   [ negative_flare_offset - driveway_width / 2, 0],
*/
//        #translate( [ -negative_flare_offset - driveway_width / 2, -driveway_entrance_flare_radius]) {
//            polygon( [ [ negative_flare_offset + driveway_width + positive_flare_offset, driveway_entrance_flare_radius]);
//        }
}

//driveway_entrance( 30);

/* West driveway entrance */
/*
module position_driveway_entrance_west() {
    position_lot_lines() {
        rotate( [ 0, 0, southwest_boundary_angle]) {
            translate( [ driveway_setback, 0]) {
                children();
            }
        }
    }
}
module meter() {
    position_meter() {
        rotate( [ 0, 0, 45]) {
            %square( [ 5 * ft, 1 * ft]);
        }
    }
}

}
*/

module driveway() {
}


/*
            // Loop Driveway
            translate( [ 6 * ft - southwest_boundary_length, 0]) {
                driveway_straightaway_length = 50 * ft;
                square( [ 12 * ft, driveway_straightaway_length]);
                driveway_inner_radius = 25 * ft;
                driveway_outer_radius = driveway_inner_radius + 12 * ft;
                translate( [ driveway_outer_radius, driveway_straightaway_length]) {
                    difference() {
                        pieSlice( size = driveway_outer_radius, start_angle = 55, end_angle = 180);
                        circle( r = driveway_inner_radius);
                    }
                    rotate( [ 0, 0, 55]) {
                        translate( [ driveway_inner_radius, -50 * ft]) {
                            square( [ 12 * ft, 50 * ft]);
                            translate( [ -driveway_inner_radius, 0]) {
                                difference() {
                                    pieSlice( size = driveway_outer_radius, start_angle = -55, end_angle = 0);
                                    circle( r = driveway_inner_radius);
                                }
                                rotate( [ 0, 0, -55]) {
                                    translate( [ driveway_inner_radius, -21.5 * ft]) {
                                        square( [ 12 * ft, 21.5 * ft]);
                                    }
                                }
                            }
                        }
                    }
                }
            }
*/

/*
module driveway() {
    driveway_width = 12 * ft;
    driveway_corner_radius = 5 * ft;
    northwest_garage_pad_depth = 20 * ft;
    position_northwest_garage() {
        translate( [ -exterior_wall_thickness, 0]) {
            difference() {
                hull() {
                    square( [ 1 * in, northwest_garage_y]);
                    translate( [ -20 * ft, northwest_garage_y - driveway_corner_radius]) {
                        circle( r = driveway_corner_radius);
                    }
                    translate( [ -15 * ft - driveway_width * 2, -driveway_width]) {
                        circle( r = driveway_width * 2.5);
                    }
                }
                translate( [ -15 * ft - driveway_width * 2, -driveway_width]) {
                    circle( r = driveway_width);
                }
            }
        }
    }
}

%driveway();
*/

module floorplan() {

    lot_lines();
    rock();
    bigtree();
    meter();
    //drivewaycircle();
    //driveway();

    upperfloor_walls_2d();
    upperfloor_fixtures();
}

rotate( [ 0, 0, -southwest_boundary_angle]) {
    translate( vector_difference( [0, 0], building_area_west_corner)) {
        floorplan();
    }
}
