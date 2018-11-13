include <shower.scad>;

accent_tile_vertical=false;
function tile_landscape() = true;

function accent_width() = 3*(mm(75)+grout_width())-grout_width();

//function back_wall_shelf_rough_depth() = inches(3.5);
function back_wall_shelf_rough_depth() = 0;

function handheld_y_offset_rough_center() = inches(25.5);
function handheld_z_offset_rough_center() = inches(48);

function showerhead_y_offset_rough_center() = inches(25.5);
function showerhead_z_offset_rough_center() = inches(83);

// back wall
function back_wall_rough_width() = inches(47.5);
function back_wall_row_width() = back_wall_rough_width() - 2 * wall_prep_thickness();
function back_wall_columns() = force_odd(width_in_tiles(back_wall_row_width()));
function back_wall_first_tile_width() = tile_width() - (width_of_tiles(back_wall_columns()) - back_wall_row_width()) / 2;
function back_wall_last_tile_width() = back_wall_first_tile_width();
function back_wall_first_tile_height() = tile_height();

function floor_row_width() = back_wall_row_width()-2*(tile_thickness()+grout_width());
function floor_first_tile_width() = floor_tile_width() - (width_of_tiles(force_odd(width_in_tiles(floor_row_width(),tile_width=floor_tile_width())),tile_width=floor_tile_width()) - floor_row_width()) / 2;

//function control_z_offset_rough_center() = inches(43);
function control_z_offset_rough_center() = knee_rough_height()+wall_prep_thickness()-grout_width()/2-tile_height();
echo(control_z_offset_rough_center=control_z_offset_rough_center());
function bar_y_offset_rough_center() = inches(32);

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
function left_control_y_offset_rough_center() = left_wall_rough_width() - inches(15); // TODO: make consistent with right_control_y_offset_rough_center()
function left_bar_y_offset_rough_center() = bar_y_offset_rough_center();
function left_control_z_offset_rough_center() = control_z_offset_rough_center();

// right wall
function right_wall_rough_width() = left_wall_rough_width();
function right_wall_row_width() = right_wall_rough_width() - 2 * wall_prep_thickness() - tile_thickness();
function right_wall_columns() = width_in_tiles(right_wall_row_width());
function right_wall_first_tile_width() = knee_rough_thickness()+drywall_thickness()+wall_prep_thickness()+tile_thickness();
//function right_wall_first_tile_width() = left_wall_first_tile_width();//tile_width()-grout_width()-back_wall_first_tile_width(); //inches(3.5)-grout_width();
function right_wall_last_tile_width() = tile_width();
function right_wall_rough_height() = ceiling_height();
function right_wall_row_height() = right_wall_rough_height() - ceiling_thickness() - floor_prep_thickness();
function right_control_y_offset_rough_center() = inches(45.5); // TODO: make consistent with left_control_y_offset_rough_center()
function right_bar_y_offset_rough_center() = bar_y_offset_rough_center();
function right_control_z_offset_rough_center() = control_z_offset_rough_center();

function knee_rough_height() = inches(54);
function knee_rough_thickness() = inches(5.5);

echo(knee_rough_height=knee_rough_height());

function left_wall_cubby_z_offset() = knee_rough_height() + wall_prep_thickness() - grout_width();
function left_wall_cubby_height() = grout_width() + tile_height() + grout_width();
function left_wall_cubby_width() = tile_width() + 2*grout_width();
function left_wall_cubby_left_offset() = inches(5.5)+wall_prep_thickness()+tile_thickness();
function left_wall_cubby_depth() = inches(3.5);

echo(left_wall_cubby_center=left_wall_cubby_left_offset()+left_wall_cubby_width()/2);
echo(left_wall_cubby_width=left_wall_cubby_width());
echo(left_wall_cubby_z_offset=left_wall_cubby_z_offset());

function back_wall_cubby_z_offset() = knee_rough_height() + wall_prep_thickness() - grout_width() - tile_height() - grout_width();
function back_wall_cubby_height() = grout_width() + tile_height() + grout_width();
function back_wall_cubby_width() = tile_width() + 2*grout_width();
function back_wall_cubby_left_offset() = wall_prep_thickness()+back_wall_first_tile_width();
function back_wall_cubby_depth() = inches(3.5);

echo(back_wall_cubby_width=back_wall_cubby_width());
echo(back_wall_cubby_z_offset=back_wall_cubby_z_offset());

module shower_tile_surround() {

//    accent_x_rough_offset=(showerhead_y_offset_rough_center()+bar_y_offset_rough_center())/2-accent_width()/2;
//    accent_x_rough_offset=left_wall_rough_width()/2-accent_width()/2;
//    accent_x_offset=accent_x_rough_offset-(wall_prep_thickness()+tile_thickness()+2*grout_width());
    accent_x_offset=right_wall_first_tile_width()+grout_width()+tile_width()+grout_width()/2-accent_width()/2;

    back_wall_width = back_wall_rough_width()-2*wall_prep_thickness();
    lower_surround_height=knee_rough_height()+wall_prep_thickness()-grout_width()-floor_prep_thickness();
    upper_surround_height=right_wall_rough_height()-(knee_rough_height()+wall_prep_thickness());
    right_side_wall_width=right_wall_rough_width()+drywall_thickness()-(wall_prep_thickness()+tile_thickness()+grout_width());
    endcap_width=drywall_thickness()+knee_rough_thickness()+wall_prep_thickness()+tile_thickness();
    left_side_wall_width=left_wall_rough_width()+drywall_thickness()-(wall_prep_thickness()+tile_thickness()+grout_width());
    left_upper_side_wall_width=left_side_wall_width;
    left_lower_side_wall_width=left_side_wall_width-knee_rough_thickness()-back_wall_shelf_rough_depth()-(wall_prep_thickness()+tile_thickness()+grout_width());

    translate([0, 0, knee_rough_height()+wall_prep_thickness()-grout_width()]) {
        translate([0, -back_wall_shelf_rough_depth()-wall_prep_thickness(), 0]) {

            // lower back wall
            translate([wall_prep_thickness(), 0, 0]) {
                tile_grid(width=back_wall_width,height=-lower_surround_height,first_tile_width=back_wall_first_tile_width());
            }

            // back wall shelf
//            translate([wall_prep_thickness()+tile_thickness()+grout_width(), -tile_thickness(), grout_width()]) {
//                rotate([-90,0,0]) tile_grid(width=back_wall_rough_width()-2*(wall_prep_thickness()+tile_thickness()+grout_width()),height=back_wall_shelf_rough_depth()-grout_width(),first_tile_width=back_wall_first_tile_width()-tile_thickness()-grout_width());
//            }

            right_lower_side_wall_width=right_side_wall_width-back_wall_shelf_rough_depth();

            // lower left wall
            translate([wall_prep_thickness(), -left_lower_side_wall_width-tile_thickness()-grout_width(), 0]) {
                rotate([0,0,90]) tile_grid(width=left_lower_side_wall_width,height=-lower_surround_height);
            }

            if (accent_tile_vertical) {
                pre_accent_width=accent_x_offset-grout_width()-back_wall_shelf_rough_depth();
                right_post_accent_width=right_side_wall_width-pre_accent_width-grout_width()-accent_width()-grout_width();

                // lower right wall
                translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                    rotate([0,0,-90]) tile_grid(width=pre_accent_width,height=-lower_surround_height,first_tile_width=right_wall_first_tile_width()-grout_width()-back_wall_shelf_rough_depth());
                    translate([0, -pre_accent_width-grout_width()-accent_width()-grout_width(), 0]) {
                        rotate([0,0,-90]) tile_grid(width=right_post_accent_width,height=-lower_surround_height,first_tile_width=tile_width()-((right_side_wall_width-right_post_accent_width-right_wall_first_tile_width())%(tile_width()+grout_width())));
                    }
                }

                // right wall accent
                translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()+pre_accent_width+grout_width()), -lower_surround_height]) {
                    rotate([0,0,-90]) {
                        accent_tile(width=accent_width(),length=right_wall_rough_height(),seed=92821);
                    }
                }

            } else {
                // lower right wall
*                translate([back_wall_rough_width()-wall_prep_thickness(), -right_side_wall_width-(tile_thickness()+grout_width()), 0]) {
                    rotate([0,0,-90]) tile_grid(width=-right_lower_side_wall_width,height=-lower_surround_height,first_tile_width=endcap_width);
                }
            }
        }

        // left knee wall
        translate([wall_prep_thickness(), -left_wall_rough_width()+knee_rough_thickness()+wall_prep_thickness(), 0]) {
            width=left_wall_knee_rough_width()-grout_width();
            translate([width,0,0]) {
                rotate([0,0,180]) tile_grid(width=width,height=-lower_surround_height);
            }
        }
        translate([left_wall_knee_rough_width()+wall_prep_thickness(), -left_wall_rough_width()-drywall_thickness(), 0]) {
            rotate([0,0,90]) tile_grid(width=endcap_width,height=-lower_surround_height);
        }
        translate([wall_prep_thickness()+tile_thickness()+grout_width(), -left_wall_rough_width()-drywall_thickness(), grout_width()]) {
            width=left_wall_knee_rough_width()-grout_width();
            twidth=tile_width()>=tile_height()?tile_width():tile_height();
            theight=tile_width()>=tile_height()?tile_height():tile_width();
            rotate([-90,0,0]) tile_grid(width=width,height=endcap_width,tile_width=twidth,tile_height=theight);
        }
    }

    // upper surround
    translate([0, -wall_prep_thickness(), knee_rough_height()+wall_prep_thickness()]) {

        if (accent_tile_vertical) { // vertical accent

            // upper back wall
            translate([wall_prep_thickness(), 0, 0]) {
                tile_grid(width=back_wall_width,height=upper_surround_height,first_tile_width=back_wall_first_tile_width());
            }

            // upper left wall
            translate([wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,90]) tile_grid(width=-left_upper_side_wall_width,height=upper_surround_height,first_tile_width=left_wall_first_tile_width());
            }

            pre_accent_width=accent_x_offset;
            right_post_accent_width=right_side_wall_width-pre_accent_width-grout_width()-accent_width()-grout_width();

            // upper right wall
            translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,-90]) tile_grid(width=pre_accent_width,height=upper_surround_height,first_tile_width=right_wall_first_tile_width());
                translate([0, -pre_accent_width-grout_width()-accent_width()-grout_width(), 0]) {
                    rotate([0,0,-90]) tile_grid(width=right_post_accent_width,height=upper_surround_height,first_tile_width=tile_width()-((right_side_wall_width-right_post_accent_width-right_wall_first_tile_width())%(tile_width()+grout_width())));
                }
            }

        } else { // horizontal accent

            sliver_height = (tile_height() - accent_width() - 2*grout_width()) / 2;

            // upper back wall
            translate([wall_prep_thickness(), 0, 0]) {
                translate([0, 0, tile_height()-sliver_height]) {
                    tile_grid(width=back_wall_width,height=upper_surround_height-tile_height()+sliver_height,first_tile_width=back_wall_first_tile_width(),first_tile_height=sliver_height);
                    translate([0,0,-grout_width()]) rotate([0,90,0]) accent_tile(width=accent_width(),length=back_wall_width,seed=8481);
                }
                tile_grid(width=back_wall_width,height=sliver_height,first_tile_width=back_wall_first_tile_width());
            }

            // upper left wall
            translate([wall_prep_thickness(), -left_wall_rough_width()+wall_prep_thickness()-drywall_thickness(), 0]) {
                rotate([0,0,90]) {
                    translate([0, 0, tile_height()-sliver_height]) {
                        tile_grid(width=left_upper_side_wall_width,height=upper_surround_height-tile_height()+sliver_height,first_tile_width=endcap_width,first_tile_height=sliver_height);
                        translate([0,0,-grout_width()]) rotate([0,90,0]) accent_tile(width=accent_width(),length=left_upper_side_wall_width,seed=25);
                    }
                    tile_grid(width=left_upper_side_wall_width,height=sliver_height,first_tile_width=endcap_width);
                }
            }

            // upper right wall
 *           translate([back_wall_rough_width()-wall_prep_thickness(), -right_side_wall_width-(tile_thickness()+grout_width()), 0]) {
                rotate([0,0,-90]) {
                    translate([0, 0, tile_height()-sliver_height]) {
                        tile_grid(width=-right_side_wall_width,height=upper_surround_height-tile_height()+sliver_height,first_tile_width=endcap_width,first_tile_height=sliver_height);
                        translate([-right_side_wall_width,0,-grout_width()]) rotate([0,90,0]) accent_tile(width=accent_width(),length=right_side_wall_width,seed=188);
                    }
                    tile_grid(width=-right_side_wall_width,height=sliver_height,first_tile_width=endcap_width);
                }
            }
        }
    }


    // floor
    floor_depth = left_wall_rough_width() - knee_rough_thickness() - back_wall_shelf_rough_depth() - 2*(wall_prep_thickness()+tile_thickness()+grout_width());
    color([0.4,0.4,0.41],floor_tile_alpha) {
        translate([wall_prep_thickness()+tile_thickness()+grout_width(), -back_wall_shelf_rough_depth()-wall_prep_thickness()-tile_thickness()-grout_width(), floor_prep_thickness()]) {
            translate([0,-floor_depth,0]) {
                rotate([atan(floor_slope()),0,0]) {
                    translate([floor_row_width(),floor_depth,0]) {
                        rotate([-90,0,180]) {
                            tile_grid(width=floor_row_width(),height=floor_depth,first_tile_width=floor_first_tile_width(),first_tile_height=right_wall_first_tile_width()-back_wall_shelf_rough_depth(),tile_width=floor_tile_width(),tile_height=floor_tile_height(),tile_thickness=floor_tile_thickness());
                        }
                    }
                }
            }
        }
    }
}


module shower() {
    union() {
union() {
        difference() {
            shower_tile_surround();

            translate([0,-left_control_y_offset_rough_center(),control_z_offset_rough_center()]) {
                rotate([0,90,0]) cylinder(h=feet(1),d=inches(5),center=false);
            }

            translate([0,-showerhead_y_offset_rough_center(),showerhead_z_offset_rough_center()]) {
                rotate([0,90,0]) cylinder(h=feet(1),d=inches(1),center=false);
            }

            translate([0,-handheld_y_offset_rough_center(),handheld_z_offset_rough_center()]) {
                rotate([0,90,0]) cylinder(h=feet(1),d=inches(1),center=false);
            }

            translate([0,-left_wall_rough_width()+left_wall_cubby_left_offset(),left_wall_cubby_z_offset()]) {
                cube([feet(1),left_wall_cubby_width(),left_wall_cubby_height()]);
            }

            translate([back_wall_cubby_left_offset(),-feet(1),back_wall_cubby_z_offset()]) {
                cube([back_wall_cubby_width(),feet(1),back_wall_cubby_height()]);
            }
        }
        color([1, 1, 1, ceiling_alpha]) translate([0,-left_wall_rough_width(),ceiling_height()]) cube([back_wall_rough_width(),left_wall_rough_width(),ceiling_thickness()]);

        // back wall cubby
        translate([back_wall_cubby_left_offset(),-wall_prep_thickness(),back_wall_cubby_z_offset()]) {
            shower_cubby(width=back_wall_cubby_width(),height=back_wall_cubby_height(),depth=back_wall_cubby_depth(),
                    grout_inside_top=true,grout_inside_bottom=true,grout_inside_left=true,grout_inside_right=true);
        }

        // left wall cubby
        translate([wall_prep_thickness(),-left_wall_rough_width()+left_wall_cubby_left_offset(),left_wall_cubby_z_offset()]) rotate([0,0,90]) {
            shower_cubby(width=left_wall_cubby_width(),height=left_wall_cubby_height(),depth=left_wall_cubby_depth(),
                    grout_inside_top=true,grout_inside_bottom=true,grout_inside_left=true,grout_inside_right=true);
        }

        color([.9, .9, .9, shower_bar_alpha]) {
            union() {
                translate([wall_prep_thickness()+tile_thickness()+bar_standoff(),-bar_y_offset_rough_center(),bar_z_offset()]) {
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

}

        color("Tan",stud_alpha) {
            difference() {
                translate([-inches(5.5),0,0]) {
                    cube([back_wall_rough_width()+2*inches(5.5),inches(5.5),ceiling_height()]);
                }
                translate([inches(1.5),-inches(1),-inches(1)]) {
                    cube([back_wall_rough_width()-2*inches(1.5),inches(2)+inches(5.5),knee_rough_height()+feet(1)]);
                }
            back_wall_cubby_offsets=[back_wall_cubby_left_offset()-tile_thickness()-wall_prep_thickness(),-feet(1),back_wall_cubby_z_offset()+grout_width()-wall_prep_thickness()];
            echo(back_wall_cubby_offsets=back_wall_cubby_offsets);
            translate(back_wall_cubby_offsets) {
                back_wall_cubby_rough=[back_wall_cubby_width()+2*(tile_thickness()+wall_prep_thickness()),back_wall_cubby_depth()+feet(1),back_wall_cubby_height()+2*wall_prep_thickness()+tile_thickness()];
                echo(back_wall_cubby_rough=back_wall_cubby_rough);
                cube(back_wall_cubby_rough);
            }
            }

//            translate([0,-back_wall_shelf_rough_depth(),0]) {
//                cube([back_wall_rough_width(),back_wall_shelf_rough_depth(),knee_rough_height()]);
//            }

            difference() {
                translate([0,-left_wall_rough_width(),0]) {
                    translate([-inches(5.5),inches(5.5),0]) {
                        cube([inches(5.5),left_wall_rough_width()-inches(5.5),left_wall_rough_height()]);
                    }
                }
                cubby_offsets=[-left_wall_cubby_depth(),-left_wall_rough_width()+inches(5.5),knee_rough_height()];
                echo(left_wall_cubby_offsets=cubby_offsets);
                translate(cubby_offsets) {
                    cubby_rough=[left_wall_cubby_depth()+feet(1),left_wall_cubby_width()+2*(tile_thickness()+wall_prep_thickness()),wall_prep_thickness()+left_wall_cubby_height()+tile_thickness()+wall_prep_thickness()];
                    echo(left_wall_cubby_rough=cubby_rough);
                    cube(cubby_rough);
                }

                translate([-inches(2),-left_control_y_offset_rough_center(),control_z_offset_rough_center()]) {
                    rotate([0,90,0]) cylinder(h=feet(1),d=inches(5),center=false);
                }

                translate([-inches(2),-showerhead_y_offset_rough_center(),showerhead_z_offset_rough_center()]) {
                    rotate([0,90,0]) cylinder(h=feet(1),d=inches(1),center=false);
                }

                translate([-inches(2),-handheld_y_offset_rough_center(),handheld_z_offset_rough_center()]) {
                    rotate([0,90,0]) cylinder(h=feet(1),d=inches(1),center=false);
                }

            }

            color([0,0,1,stud_alpha]) translate([-inches(2),-left_control_y_offset_rough_center(),control_z_offset_rough_center()]) {
                rotate([0,90,0]) cylinder(h=inches(4),d=inches(5),center=false);
            }


            translate([0,-left_wall_rough_width(),0]) {
                translate([-feet(1)-inches(5.5),0,0]) {
                    cube([feet(1)+inches(5.5),inches(5.5),left_wall_rough_height()]);
                }
                cube([left_wall_knee_rough_width(),knee_rough_thickness(),knee_rough_height()]);
            }
*            translate([back_wall_rough_width(),-right_wall_rough_width()-feet(1),0]) {
                cube([inches(5.5),right_wall_rough_width()+feet(1),left_wall_rough_height()]);
            }
        }

        color([0.66,0.7,1.0],drywall_alpha) union() {
            translate([0,-left_wall_rough_width(),0]) {
//                cube([drywall_thickness(),left_wall_rough_width(),left_wall_rough_height()]);
                translate([0,-drywall_thickness(),0]) {
                    translate([drywall_thickness(),0,0]) cube([left_wall_knee_rough_width()-drywall_thickness()+wall_prep_thickness()-grout_width(),drywall_thickness(),knee_rough_height()+wall_prep_thickness()-grout_width()]);
                    translate([-feet(1)-inches(5.5),0,0]) {
                        cube([feet(1)+inches(5.5)+drywall_thickness(),drywall_thickness(),left_wall_rough_height()]);
                    }
                }
            }

*            translate([back_wall_rough_width()-drywall_thickness(),-right_wall_rough_width()-feet(1),0]) {
                cube([drywall_thickness(),right_wall_rough_width()+feet(1),right_wall_rough_height()]);
            }

/*
            translate([0,-drywall_thickness(),0]) {
                cube([back_wall_rough_width(),drywall_thickness(),right_wall_rough_height()]);
            }

            translate([0,-back_wall_shelf_rough_depth(),0]) {
                cube([back_wall_rough_width(),back_wall_shelf_rough_depth(),knee_rough_height()]);
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

    line_thickness=mm(4);

*    color([0,1,0,1]) {
        translate([0,0,knee_rough_height()]) {
            translate([-line_thickness/2,-left_wall_rough_width()-line_thickness/2,-line_thickness/2]) {
                cube([left_wall_knee_rough_width()+line_thickness,line_thickness,line_thickness]);
            }
            translate([-line_thickness/2,-left_wall_rough_width()-line_thickness/2,-line_thickness/2]) {
                cube([line_thickness,left_wall_rough_width()+line_thickness,line_thickness]);
            }
            translate([-line_thickness/2,-line_thickness/2,-line_thickness/2]) {
                cube([back_wall_rough_width()+line_thickness,line_thickness,line_thickness]);
            }
        }
    }

*    color([0,0,1,1]) {
        translate([0,0,knee_rough_height()+wall_prep_thickness()-grout_width()-tile_height()-wall_prep_thickness()]) {
            translate([-line_thickness/2,-line_thickness/2,-line_thickness/2]) {
                cube([back_wall_rough_width()+line_thickness,line_thickness,line_thickness]);
            }
            translate([-line_thickness/2,-line_thickness/2,-line_thickness/2+back_wall_cubby_height()+2*wall_prep_thickness()+tile_thickness()]) {
                cube([back_wall_rough_width()+line_thickness,line_thickness,line_thickness]);
            }
        }
        translate([back_wall_cubby_left_offset()-tile_thickness()-wall_prep_thickness()-line_thickness/2,-line_thickness/2,knee_rough_height()-feet(2)-line_thickness/2]) {
            cube([line_thickness,line_thickness,feet(3)+line_thickness]);
            translate([back_wall_cubby_width()+2*(tile_thickness()+wall_prep_thickness()),0,0]) {
                cube([line_thickness,line_thickness,feet(3)+line_thickness]);
            }
        }


        translate([0,0,knee_rough_height()]) {
            translate([-line_thickness/2,-left_wall_rough_width()-line_thickness/2,-line_thickness/2+left_wall_cubby_height()+2*wall_prep_thickness()+tile_thickness()]) {
                cube([line_thickness,knee_rough_thickness()+left_wall_cubby_width()+feet(1)+line_thickness,line_thickness]);
            }
        }
        translate([-line_thickness/2,-left_wall_rough_width()+knee_rough_thickness()-line_thickness/2,knee_rough_height()-feet(1)-line_thickness/2]) {
            cube([line_thickness,line_thickness,feet(3)+line_thickness]);
            translate([0,left_wall_cubby_width()+2*(tile_thickness()+wall_prep_thickness()),0]) {
                cube([line_thickness,line_thickness,feet(3)+line_thickness]);
            }
        }
    }

*    color([1,0,1,1]) {
        translate([0,-showerhead_y_offset_rough_center()-line_thickness/2,showerhead_z_offset_rough_center()-line_thickness/2]) {
            translate([0,0,-feet(2)]) cube([line_thickness,line_thickness,feet(3)+line_thickness]);
            translate([0,-feet(1),0]) cube([line_thickness,feet(2)+line_thickness,line_thickness]);
        }
        translate([0,-handheld_y_offset_rough_center()-line_thickness/2,handheld_z_offset_rough_center()-line_thickness/2]) {
            translate([0,0,-feet(1)]) cube([line_thickness,line_thickness,feet(3)+line_thickness]);
            translate([0,-feet(1),0]) cube([line_thickness,feet(2)+line_thickness,line_thickness]);
        }
        translate([0,-left_control_y_offset_rough_center()-line_thickness/2,left_control_z_offset_rough_center()-line_thickness/2]) {
            translate([0,0,-feet(1)]) cube([line_thickness,line_thickness,feet(2)+line_thickness]);
            translate([0,-feet(1),0]) cube([line_thickness,feet(2)+line_thickness,line_thickness]);
        }
    }
}

// Standalone rendering
shower();
