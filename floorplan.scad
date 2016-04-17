include <units.scad>;
include <lot.scad>;
include <building_area.scad>;
include <MCAD/2Dshapes.scad>;

default_font = "Comic Sans MS:style=Regular";

exterior_wall_thickness = 5.5 * in + 1.5 * in + 0.5 * in;
interior_wall_thickness = 3.5 * in + 0.5 * in + 0.5 * in;

/* View guidelines */

view_x = ( 40 + 15 + 35 + 25) * ft;
module position_view() {
    children();
}
module view() {
    thickness = interior_wall_thickness;
    gap = 2 * exterior_wall_thickness;
    corner_y = 2 * ft;
    position_view() {
        union() {
            translate( [ -thickness - gap, gap + thickness - corner_y]) {
                square( [ thickness, 2 * ft]);
            }
            translate( [ -gap - 1 * in, gap]) {
                square( [ gap + 1 * in + 40 * ft, thickness]);
            }
        }
        translate( [ 40 * ft + 15 * ft, gap]) {
            square( [ 35 * ft, thickness]);
        }
        union() {
            translate( [ view_x, gap]) {
                square( [ gap + 1 * in, thickness]);
            }
            translate( [ view_x + gap, gap + thickness - corner_y]) {
                square( [ thickness, 2 * ft]);
            }
        }
    }
}

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

/* Mudroom */

mudroom_x = 4 * ft + pantry_x + interior_wall_thickness + kitchen_backwall_x;
mudroom_y = 8 * ft;
module position_mudroom() {
    position_greatroom() {
        translate( [ greatroom_x - mudroom_x, -mudroom_y - interior_wall_thickness]) {
            children();
        }
    }
}
module mudroom() {
    position_mudroom() {
        square( [ mudroom_x, mudroom_y]);
    }
}

/* Greatroom */

greatroom_x = 25 * ft;
greatroom_y = diningarea_y + interior_wall_thickness + kitchen_y;
module position_greatroom() {
    position_view() {
        translate( [ view_x - greatroom_x, -greatroom_y]) {
            children();
        }
    }
}
module greatroom() {
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
}

/* Garage 1 */

garage1_x = greatroom_x;
garage1_y = 24 * ft;
module position_garage1() {
    position_mudroom() {
        translate( [ mudroom_x - garage1_x, -exterior_wall_thickness - garage1_y]) {
            children();
        }
    }
}
module garage1() {
    position_garage1() {
        square( [ garage1_x, garage1_y]);
    }
}

/* Laundry room */

laundryroom_x = garage1_x - mudroom_x - interior_wall_thickness;
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


/* Stairs */

// TODO: figure out stairs to loft, too, including landing (turn?)
stairs_x = 16 * ft; // TODO: calculate from pitch and basement depth
stairs_y = 3 * ft;
module position_stairs() {
    position_entrance() {
        translate( [ -stairs_x, 0]) {
            children();
        }
    }
}
module stairs() {
    position_stairs() {
        square( [ stairs_x + 1 * in, stairs_y]);
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
    pantry();
    laundryroom();
    mudroom();
    garage1();

    hallway();
    stairs();
    entrance();

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

module fixtures() {
    kitchen_fixtures();
}

module walls() {
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
module position_lot() {
    translate( [ view_x + 20 * ft, -southeast_boundary_length / 2 + 20 * ft]) {
        rotate( [ 0, 0, 90 - southeast_boundary_angle]) {
            translate( vector_difference( west_corner, south_corner)) {
                children();
            }
        }
    }
}
module lot() {
    position_lot() {
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

/* Big rock next to driveway */
module position_rock() {
    position_lot() {
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
    position_lot() {
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
    position_lot() {
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
    position_lot() {
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
    position_lot() {
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

lot();
rock();
bigtree();
meter();
//drivewaycircle();
driveway();

/*
module driveway() {
    driveway_width = 12 * ft;
    driveway_corner_radius = 5 * ft;
    garage_pad_depth = 20 * ft;
    position_garage1() {
        translate( [ -exterior_wall_thickness, 0]) {
            difference() {
                hull() {
                    square( [ 1 * in, garage1_y]);
                    translate( [ -20 * ft, garage1_y - driveway_corner_radius]) {
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

%view();
walls();
fixtures();
