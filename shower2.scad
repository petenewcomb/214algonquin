include <shower.scad>;

function accent_width() = inches(18);

// back wall
function back_wall_rough_width() = inches(47.5);
function back_wall_row_width() = back_wall_rough_width() - 2 * wall_prep_thickness();
function back_wall_columns() = force_odd(width_in_tiles(back_wall_row_width()));
function back_wall_first_tile_width() = tile_width() - (width_of_tiles(back_wall_columns()) - back_wall_row_width()) / 2;
function back_wall_last_tile_width() = back_wall_first_tile_width();
function back_wall_first_tile_height() = tile_height();

function floor_row_width() = back_wall_row_width()-2*(tile_thickness()+grout_width());
function floor_first_tile_width() = floor_tile_width() - (width_of_tiles(force_odd(width_in_tiles(floor_row_width(),tile_width=floor_tile_width())),tile_width=floor_tile_width()) - floor_row_width()) / 2;

function control_z_offset_rough_center() = inches(42);

function ceiling_height() = inches(109) - inches(0.5);
function ceiling_thickness() = inches(1);

// left wall
function left_wall_rough_width() = inches(72.75);
function left_wall_row_width() = left_wall_rough_width() - 2 * wall_prep_thickness() - tile_thickness();
function left_wall_columns() = width_in_tiles(left_wall_row_width());
function left_wall_first_tile_width() = tile_width()-grout_width()-back_wall_first_tile_width(); //inches(3.5)-grout_width();
function left_wall_last_tile_width() = left_wall_row_width()-width_of_tiles(left_wall_columns()-2)-2*grout_width()-left_wall_first_tile_width();
function left_wall_knee_rough_width() = inches(12);
function left_wall_rough_height() = ceiling_height();
function left_wall_row_height() = left_wall_rough_height() - ceiling_thickness() - floor_prep_thickness();
function left_control_y_offset_rough_center() = inches(45); // TODO: make consistent with right_control_y_offset_rough_center()
function left_bar_y_offset_rough_center() = bar_y_offset_rough_center();
function left_control_z_offset_rough_center() = control_z_offset_rough_center();

// right wall
function right_wall_rough_width() = inches(68.125);
function right_wall_row_width() = right_wall_rough_width() - 2 * wall_prep_thickness() - tile_thickness();
function right_wall_columns() = width_in_tiles(right_wall_row_width());
function right_wall_first_tile_width() = tile_width()-grout_width()-back_wall_first_tile_width(); //inches(3.5)-grout_width();
function right_wall_last_tile_width() = tile_width();
function right_wall_rough_height() = ceiling_height();
function right_wall_row_height() = right_wall_rough_height() - ceiling_thickness() - floor_prep_thickness();
function right_control_y_offset_rough_center() = inches(45.5); // TODO: make consistent with left_control_y_offset_rough_center()
function right_bar_y_offset_rough_center() = bar_y_offset_rough_center();
function right_control_z_offset_rough_center() = control_z_offset_rough_center();

function knee_rough_height() = inches(47);
function knee_rough_thickness() = inches(5.5);

echo(knee_rough_height=knee_rough_height());


module shower_tile_surround() {

//    accent_x_rough_offset=(showerhead_y_offset_rough_center()+bar_y_offset_rough_center())/2-accent_width()/2;
    accent_x_rough_offset=left_wall_rough_width()/2-accent_width()/2;
    accent_x_offset=accent_x_rough_offset-(wall_prep_thickness()+tile_thickness()+2*grout_width());

    back_wall_width = back_wall_rough_width()-2*wall_prep_thickness();
    lower_surround_height=knee_rough_height()+wall_prep_thickness()-grout_width()-floor_prep_thickness();
    upper_surround_height = right_wall_rough_height()-(knee_rough_height()+wall_prep_thickness());

    translate([0, -wall_prep_thickness(), knee_rough_height()+wall_prep_thickness()-grout_width()]) {

        // lower back wall
        translate([wall_prep_thickness(), 0, 0]) {
            tile_grid(width=back_wall_width,height=-lower_surround_height,first_tile_width=back_wall_first_tile_width());
        }

        lower_side_wall_width=left_wall_rough_width()-knee_rough_thickness()-2*(wall_prep_thickness()+tile_thickness()+grout_width());

        if (accent_tile_vertical) {
            pre_accent_width=accent_x_offset-grout_width();
            post_accent_width=lower_side_wall_width-pre_accent_width-grout_width()-accent_width()-grout_width();

            // lower left wall
            translate([wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,90]) translate([-pre_accent_width,0,0]) tile_grid(width=pre_accent_width,height=-lower_surround_height);
                translate([0, -pre_accent_width-grout_width()-accent_width()-grout_width(), 0]) {
                    rotate([0,0,90]) tile_grid(width=-post_accent_width,height=-lower_surround_height);
                }
            }

            // lower right wall
            translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,-90]) translate([pre_accent_width,0,0]) tile_grid(width=-pre_accent_width,height=-lower_surround_height);
                translate([0, -pre_accent_width-grout_width()-accent_width()-grout_width(), 0]) {
                    rotate([0,0,-90]) tile_grid(width=post_accent_width,height=-lower_surround_height);
                }
            }

            // left wall accent
            translate([wall_prep_thickness(), -(tile_thickness()+grout_width()+pre_accent_width+grout_width()+accent_width()), -lower_surround_height]) {
                rotate([0,0,90]) {
                    accent_tile(width=accent_width(),length=left_wall_rough_height(),seed=8241);
                }
            }

            // right wall accent
            translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()+pre_accent_width+grout_width()), -lower_surround_height]) {
                rotate([0,0,-90]) {
                    accent_tile(width=accent_width(),length=right_wall_rough_height(),seed=28281);
                }
            }

        } else {
            // lower left wall
            translate([wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,90]) tile_grid(width=-lower_side_wall_width,height=-lower_surround_height,first_tile_width=tile_width());
            }
            // lower right wall
            translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,-90]) tile_grid(width=lower_side_wall_width,height=-lower_surround_height,first_tile_width=tile_width());
            }
        }

        endcap_width=drywall_thickness()+knee_rough_thickness()+wall_prep_thickness()+tile_thickness();

        // left knee wall
        translate([wall_prep_thickness(), -lower_side_wall_width-2*(grout_width()+tile_thickness()), 0]) {
            width=left_wall_knee_rough_width()-grout_width();
            translate([width,0,0]) {
                rotate([0,0,180]) tile_grid(width=width,height=-lower_surround_height);
            }
        }
        translate([left_wall_knee_rough_width()+wall_prep_thickness(), -left_wall_rough_width()-drywall_thickness()+wall_prep_thickness(), 0]) {
            rotate([0,0,90]) tile_grid(width=endcap_width,height=-lower_surround_height);
        }
        translate([wall_prep_thickness()+tile_thickness()+grout_width(), -left_wall_rough_width()-drywall_thickness()+wall_prep_thickness(), 0]) {
            width=left_wall_knee_rough_width()-grout_width();
            twidth=tile_width()>=tile_height()?tile_width():tile_height();
            theight=tile_width()>=tile_height()?tile_height():tile_width();
            rotate([-90,0,0]) tile_grid(width=width,height=endcap_width,tile_width=twidth,tile_height=theight);
        }
    }

    // upper surround
    translate([0, -wall_prep_thickness(), knee_rough_height()+wall_prep_thickness()]) {

        upper_side_wall_width=left_wall_rough_width()+drywall_thickness()-(wall_prep_thickness()+tile_thickness()+grout_width());

        if (accent_tile_vertical) { // vertical accent

            // upper back wall
            translate([wall_prep_thickness(), 0, 0]) {
                tile_grid(width=back_wall_width,height=upper_surround_height,first_tile_width=back_wall_first_tile_width());
            }

            pre_accent_width=accent_x_offset;
            post_accent_width=upper_side_wall_width-pre_accent_width-accent_width()-grout_width();

            // upper left wall
            translate([wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,90]) translate([-pre_accent_width,0,0]) tile_grid(width=pre_accent_width,height=upper_surround_height);
                translate([0, -pre_accent_width-accent_width()-grout_width(), 0]) {
                    rotate([0,0,90]) tile_grid(width=-post_accent_width,height=upper_surround_height);
                }
            }

            // upper right wall
            translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,-90]) translate([pre_accent_width,0,0]) tile_grid(width=-pre_accent_width,height=upper_surround_height);
                translate([0, -pre_accent_width-grout_width()-accent_width()-grout_width(), 0]) {
                    rotate([0,0,-90]) tile_grid(width=post_accent_width,height=upper_surround_height);
                }
            }

        } else { // horizontal accent

            // upper back wall
            translate([wall_prep_thickness(), 0, tile_height()+grout_width()]) {
                tile_grid(width=back_wall_width,height=upper_surround_height-tile_height()-grout_width(),first_tile_width=back_wall_first_tile_width());
                translate([0,0,-grout_width()]) rotate([0,90,0]) accent_tile(width=tile_height(),length=back_wall_width,seed=8481);
            }

            // upper left wall
            translate([wall_prep_thickness(), -(tile_thickness()+grout_width()), tile_height()+grout_width()]) {
                rotate([0,0,90]) tile_grid(width=-upper_side_wall_width,height=upper_surround_height-tile_height()-grout_width());
                translate([0,-upper_side_wall_width,-grout_width()]) rotate([0,90,90]) accent_tile(width=tile_height(),length=upper_side_wall_width,seed=25);
            }

            // upper right wall
            translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()), tile_height()+grout_width()]) {
                rotate([0,0,-90]) tile_grid(width=upper_side_wall_width,height=upper_surround_height-tile_height()-grout_width());
                translate([0,0,-grout_width()]) rotate([0,90,-90]) accent_tile(width=tile_height(),length=upper_side_wall_width,seed=188);
            }
        }
    }


    // floor
    floor_depth = left_wall_rough_width() - knee_rough_thickness() - 2*(wall_prep_thickness()+tile_thickness()+grout_width());
    color([0.4,0.4,0.41],floor_tile_alpha) {
        translate([wall_prep_thickness()+tile_thickness()+grout_width(), -wall_prep_thickness()-tile_thickness()-grout_width(), floor_prep_thickness()]) {
            translate([0,-floor_depth,0]) {
                rotate([atan(floor_slope()),0,0]) {
                    translate([floor_row_width(),floor_depth,0]) {
                        rotate([-90,0,180]) {
                            tile_grid(width=floor_row_width(),height=floor_depth,first_tile_width=floor_first_tile_width(),tile_width=floor_tile_width(),tile_height=floor_tile_height(),tile_thickness=floor_tile_thickness());
                        }
                    }
                }
            }
        }
    }
}


module shower() {
    union() {
        difference() {
            shower_tile_surround();

            translate([0,-left_control_y_offset_rough_center(),control_z_offset_rough_center()]) {
                rotate([0,90,0]) cylinder(h=feet(1),d=inches(5),center=false);
            }

            translate([back_wall_rough_width(),-right_control_y_offset_rough_center(),control_z_offset_rough_center()]) {
                rotate([0,-90,0]) cylinder(h=feet(1),d=inches(5),center=false);
            }

            translate([0,-showerhead_y_offset_rough_center(),showerhead_z_offset_rough_center()]) {
                rotate([0,90,0]) cylinder(h=feet(1),d=inches(1),center=false);
            }

            translate([back_wall_rough_width(),-showerhead_y_offset_rough_center(),showerhead_z_offset_rough_center()]) {
                rotate([0,-90,0]) cylinder(h=feet(1),d=inches(1),center=false);
            }

        }
        color([.247, .165, .078, ceiling_alpha]) translate([0,-left_wall_rough_width(),ceiling_height()]) cube([back_wall_rough_width(),left_wall_rough_width(),ceiling_thickness()]);

        color([.9, .9, .9, shower_bar_alpha]) {
            union() {
                translate([wall_prep_thickness()+tile_thickness()+bar_standoff(),-bar_y_offset_rough_center(),bar_z_offset()]) {
                    cylinder(h=bar_height(),d=bar_diameter(),center=false);
                }
                translate([back_wall_rough_width()-(wall_prep_thickness()+tile_thickness()+bar_standoff()),-bar_y_offset_rough_center(),bar_z_offset()]) {
                    cylinder(h=bar_height(),d=bar_diameter(),center=false);
                }
            }

            control_height=inches(6.25);
            control_width=inches(6.25);
            control_thickness=inches(9.0/16);
            translate([wall_prep_thickness()+tile_thickness(),-left_control_y_offset_rough_center()-control_width/2,control_z_offset_rough_center()-control_height/2]) {
                cube([control_thickness,control_width,control_height]);
            }
        }

        color("Tan",stud_alpha) {
            difference() {
                translate([-inches(5.5)-inches(3.5),0,0]) {
                    cube([back_wall_rough_width()+inches(5.5)+inches(3.5)+feet(1),inches(5.5),right_wall_rough_height()]);
                }
                translate([inches(1.5),-inches(1),-inches(1)]) {
                    cube([back_wall_rough_width()-2*inches(1.5),inches(2)+inches(5.5),knee_rough_height()-inches(1.5)+inches(1)]);
                }
            }

            translate([0,-left_wall_rough_width(),0]) {
                translate([-inches(3.5),0,0]) {
                    cube([inches(3.5),left_wall_rough_width(),left_wall_rough_height()]);
                    translate([-inches(5.5),-feet(1),0]) {
                        cube([inches(5.5),left_wall_rough_width()+feet(1),left_wall_rough_height()]);
                    }
                }
                cube([left_wall_knee_rough_width(),knee_rough_thickness(),knee_rough_height()]);
            }
        }

        color([0.66,0.7,1.0],drywall_alpha) union() {
            translate([0,-left_wall_rough_width()-drywall_thickness(),0]) {
//                cube([left_wall_knee_rough_width()+wall_prep_thickness()-grout_width(),drywall_thickness(),knee_rough_height()+wall_prep_thickness()-grout_width()]);
            }
            translate([-inches(3.5),-left_wall_rough_width()-drywall_thickness(),0]) {
//                cube([inches(3.5)+wall_prep_thickness()-grout_width(),drywall_thickness(),left_wall_rough_height()]);
            }

/*
            translate([0,-drywall_thickness(),0]) {
                cube([back_wall_rough_width(),drywall_thickness(),right_wall_rough_height()]);
            }
            translate([0,-left_wall_rough_width(),0]) {
                translate([-inches(3.5),0,0]) {
                    cube([inches(3.5),left_wall_rough_width(),left_wall_rough_height()]);
                    translate([-inches(5.5),-feet(1),0]) {
                        cube([inches(5.5),left_wall_rough_width()+feet(1),left_wall_rough_height()]);
                    }
                }
                cube([left_wall_knee_rough_width(),knee_rough_thickness(),knee_rough_height()]);
            }
*/
        }
    }
}

// Standalone rendering
shower();
