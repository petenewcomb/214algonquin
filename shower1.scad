use <math.scad>;

tile_alpha = 0.4;
floor_tile_alpha = 1.0;
shower_bar_alpha = 1.0;
stud_alpha = 0.3;
drywall_alpha = 1.0;
ceiling_alpha = 1.0;
accent_tile_alpha = 0.1;

simplify_accent_tile=false;

$fn = 20;

function feet( x) = inches( x) * 12;
function inches( x) = x;
function mm( x) = inches( x / 25.4);

function tile_height() = mm(300.0);
function tile_width() = mm(600.0);
function tile_thickness() = mm(9.0);
function grout_width() = inches(1.0/16);
function drywall_thickness() = inches(1.0/2);
function wall_prep_thickness() = drywall_thickness() + inches(3.0/8); // drywall + kerdi + thinset
function floor_prep_thickness() = inches(3.0/8);
function floor_tile_thickness() = inches(1.0/4);
function floor_tile_width() = inches(24+(1.0/8));
function floor_tile_height() = inches(12-(1.0/16));
function ceiling_thickness() = inches(1); // TODO: should be 3/4 * some trig function of 3/12 pitch

function width_in_tiles(width,tile_width=tile_width(),grout_width=grout_width()) = ceil((width + grout_width)/(tile_width+grout_width));
function force_odd(n) = 2*floor(n/2.0)+1;
function width_of_tiles(n,tile_width=tile_width(),grout_width=grout_width()) = n>0?n*(tile_width+grout_width)-grout_width:0;
function height_of_tiles(n,tile_height=tile_height(),grout_width=grout_width()) = width_of_tiles(n,tile_width=tile_height,grout_width=grout_width);

function back_wall_shelf_rough_depth() = inches(3.5);
function accent_width() = inches(12);

function left_wall_shim_thickness() = inches(0.25);

// back wall
function back_wall_rough_width() = inches(72.75) - left_wall_shim_thickness(); // TODO: shim left wall by 1/4"
function back_wall_row_width() = back_wall_rough_width() - 2 * wall_prep_thickness();
function back_wall_columns() = force_odd(width_in_tiles(back_wall_row_width()));
function back_wall_first_tile_width() = tile_width() - (width_of_tiles(back_wall_columns()) - back_wall_row_width()) / 2;
function back_wall_last_tile_width() = back_wall_first_tile_width();
function back_wall_first_tile_height() = tile_height();

function floor_row_width() = back_wall_row_width()-2*(tile_thickness()+grout_width());
function floor_first_tile_width() = floor_tile_width() - (width_of_tiles(force_odd(width_in_tiles(floor_row_width(),tile_width=floor_tile_width())),tile_width=floor_tile_width()) - floor_row_width()) / 2;

function floor_slope() = (1.0/8) / 12;

function window_sill_height() = inches(63.75) + floor_slope() * (left_wall_rough_width() - knee_rough_thickness()); // account for sloped subfloor
function window_sill_depth() = inches(3.5);
function window_jamb_opening_height() = inches(15.375);
function window_jamb_opening_width() = inches(45.375);
function window_jamb_opening_left_offset() = inches(13.875) - left_wall_shim_thickness();
function window_jamb_opening_right_offset() = inches(13.625);

//function foot_cubby_height() = inches(16);
function foot_cubby_height() = window_sill_height() - (knee_rough_height() + grout_width() + tile_height()/2);
function foot_cubby_depth() = inches(3.5);

echo(foot_cubby_height=foot_cubby_height());

function bar_standoff() = inches(1);
function bar_y_offset_rough_center() = inches(34);
function bar_height() = inches(36);
function bar_diameter() = inches(3.0/4);
function bar_z_offset() = inches(42);
function control_z_offset_rough_center() = inches(42);
function showerhead_y_offset_rough_center() = inches(24);
function showerhead_z_offset_rough_center() = inches(83);

// left wall
function left_wall_rough_width() = inches(62.25);
function left_wall_row_width() = left_wall_rough_width() - 2 * wall_prep_thickness() - tile_thickness();
function left_wall_columns() = width_in_tiles(left_wall_row_width());
function left_wall_first_tile_width() = tile_width()-grout_width()-back_wall_first_tile_width(); //inches(3.5)-grout_width();
function left_wall_last_tile_width() = left_wall_row_width()-width_of_tiles(left_wall_columns()-2)-2*grout_width()-left_wall_first_tile_width();
function left_wall_knee_rough_width() = inches(17.75) - left_wall_shim_thickness(); // TODO: make consistent with right_wall_knee_rough_width()
function left_wall_rough_height() = inches(99.5);
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
function right_wall_knee_rough_width() = inches(17.25); // TODO: make consistent with left_wall_knee_rough_width()
function right_wall_rough_height() = inches(117.5);
function right_wall_row_height() = right_wall_rough_height() - ceiling_thickness() - floor_prep_thickness();
function right_control_y_offset_rough_center() = inches(45.5); // TODO: make consistent with left_control_y_offset_rough_center()
function right_bar_y_offset_rough_center() = bar_y_offset_rough_center();
function right_control_z_offset_rough_center() = control_z_offset_rough_center();

//function knee_rough_height() = inches(47) + inches(3.0/16); // TODO: reduce height to 47"
function knee_rough_height() = window_sill_height() + (window_jamb_opening_height()-tile_height()) / 2 - grout_width() - tile_height() - grout_width() - tile_height() - wall_prep_thickness(); // TODO: reduce height to 47"
function knee_rough_thickness() = inches(3.5);

echo(knee_rough_height=knee_rough_height());

// shower2: 47.5x72.75x109, knee width 12", thickness 5.5"

module tile(height=tile_height(),width=tile_width(),thickness=tile_thickness(), color=[0.75,0.75,0.7,tile_alpha]) {
    translate([0,-thickness,0]) color(color) {
        if (width < inches(1) || height < inches(1) || thickness <= 0) {
            if (width <= 0 || height <= 0 || thickness <= 0) {
                echo("<font color=\"red\">ERROR: invalid tile</font>", width=width/inches(1), height=height/inches(1));
            } else {
                echo("<font color=\"orange\">WARN: small tile</font>", width=width/inches(1), height=height/inches(1));
            }
            #cube([width, thickness, height]);
        } else {
            cube([width, thickness, height]);
        }
    }
}

module tile_row(columns=0,width=0,first_tile_width=0,last_tile_width=0,tile_width=tile_width(),tile_height=tile_height(),grout_width=grout_width(),tile_thickness=tile_thickness()) {
    effective_columns = columns != 0 ? columns : sign(width)*(let (rem=abs(width) - (first_tile_width==0?tile_width:first_tile_width) - grout_width) rem < 0 ? 1 : 1 + ceil(rem / (tile_width+grout_width)));
    effective_first_tile_width = let (x=(first_tile_width==0 ? tile_width : first_tile_width)) width==0 ? x : min(x,abs(width));
    effective_last_tile_width = let (x=(last_tile_width==0 ? tile_width : last_tile_width)) width==0 ? x : min(tile_width, abs(width)-effective_first_tile_width-grout_width-((abs(effective_columns)-2)*(tile_width+grout_width)));
    x_increment = tile_width+grout_width;
    first_column_offset=effective_first_tile_width+grout_width;
    translate([effective_columns<0?-effective_first_tile_width:0,0,0]) {
        tile(width=effective_first_tile_width,height=tile_height,thickness=tile_thickness);
    }
    remaining_columns = abs(effective_columns) - 1;
    if (remaining_columns > 0) {
        translate([sign(effective_columns)*first_column_offset,0,0]) {
            for (column = [1:remaining_columns]) {
                translate([sign(effective_columns)*(column-1)*x_increment, 0, 0]) {
                    twidth=column<remaining_columns?tile_width:effective_last_tile_width;
                    translate([effective_columns<0?-twidth:0,0,0]) {
                        tile(width=twidth,height=tile_height,thickness=tile_thickness);
                    }
                }
            }
        }
    }
}

module tile_grid(rows=0,columns=0,width=0,height=0,first_tile_width=0,last_tile_width=0,tile_width=tile_width(),first_tile_height=0,last_tile_height=0,tile_height=tile_height(),grout_width=grout_width(),tile_thickness=tile_thickness()) {
    effective_rows = rows != 0 ? rows : sign(height)*(let (rem=abs(height) - (first_tile_height==0?tile_height:first_tile_height) - grout_width) rem < 0 ? 1 : 1 + ceil(rem / (tile_height+grout_width)));
    effective_first_tile_height = let (x=(first_tile_height==0 ? tile_height : first_tile_height)) height==0 ? x : min(x,abs(height));
    effective_last_tile_height = let (x=(last_tile_height==0 ? tile_height : last_tile_height)) height==0 ? x : min(tile_height, abs(height)-effective_first_tile_height-grout_width-((abs(effective_rows)-2)*(tile_height+grout_width)));
    translate([0,0,effective_rows<0?-effective_first_tile_height:0]) {
        tile_row(columns=columns,width=width,first_tile_width=first_tile_width,last_tile_width=last_tile_width,tile_width=tile_width,tile_height=effective_first_tile_height,grout_width=grout_width,tile_thickness=tile_thickness);
    }
    remaining_rows = abs(effective_rows) - 1;
    if (remaining_rows > 0) {
        translate([0,0,sign(effective_rows)*(effective_first_tile_height+grout_width)]) {
            for (row = [1:remaining_rows]) {
                translate([0, 0, sign(effective_rows)*(row-1)*(tile_height+grout_width)]) {
                    theight=row<remaining_rows?tile_height:effective_last_tile_height;
                    translate([0,0,effective_rows<0?-theight:0]) {
                        tile_row(columns=columns,width=width,first_tile_width=first_tile_width,last_tile_width=last_tile_width,tile_width=tile_width,tile_height=theight,grout_width=grout_width,tile_thickness=tile_thickness);
                    }
                }
            }
        }
    }
}

function generate_sequence_recur(target_length,choices,decision_index,decisions) =
        decision_index == (len(decisions) - 2) ? let (choice=decisions[decision_index+1]*choices[floor(decisions[decision_index]*len(choices))]) [[0, 0, min(choice,target_length)]]
        : ( let (seq=generate_sequence_recur(target_length,choices,decision_index+1,decisions))
            let (length=seq[0][1] + seq[0][2])
            length >= target_length ? seq
            : ( let (remaining_choices=[for (c=choices) if (c!=seq[0][2]) c])
                let (choice=remaining_choices[floor(decisions[decision_index]*len(remaining_choices))])
                concat([[1+seq[0][0],length,min(target_length-length,choice)]],seq)));

function generate_sequence(length,choices,seed) = generate_sequence_recur(target_length=length,choices=choices,decision_index=0,decisions=rands(min_value=0.0,max_value=1.0,value_count=1+ceil(length/min(choices)),seed));

module accent_tile(width,length) {
    thickness=inches(1.0/8);
    grout_width=inches(1.0/16);
    if (simplify_accent_tile) {
        color([0.0,0.1,0.6,accent_tile_alpha]) cube([width-grout_width,thickness,length]);
    } else {
        union() {
            choices=[inches(1.5),inches(3),inches(4.5)];
            segment_width=inches(3.0/4);
            columns = floor(width/segment_width);
            z_offsets = rands(min_value=inches(0),max_value=inches(1),value_count=columns,seed=285297);
            for (column=[0:columns-1]) {
                sequence=generate_sequence(length=length,choices=choices,seed=83957*(1+column));
                segment_is_dark = [for (x=rands(min_value=0,max_value=1,value_count=len(sequence),seed=2453*(1+column))) x>0.5];
                for (segment=sequence) {
                    segment_index=segment[0];
                    segment_offset=segment[1];
                    segment_length=segment[2];
                    translate([column*segment_width,-tile_thickness(),segment_offset]) {
                        color(segment_is_dark[segment_index]?[0.0,0.05,0.4,accent_tile_alpha]:[0.0,0.1,0.6,accent_tile_alpha]) {
                            cube([segment_width-grout_width,thickness,segment_length-grout_width]);
                        }
                    }
                }
            }
        }
    }
}

module shower_tile_surround() {

    accent_x_rough_offset=(showerhead_y_offset_rough_center()+bar_y_offset_rough_center())/2-accent_width()/2;
    accent_x_offset=accent_x_rough_offset-(wall_prep_thickness()+tile_thickness()+grout_width());

    back_wall_width = back_wall_rough_width()-2*wall_prep_thickness();

    translate([0, -back_wall_shelf_rough_depth()-wall_prep_thickness(), knee_rough_height()+wall_prep_thickness()-grout_width()]) {

        lower_surround_height=knee_rough_height()+wall_prep_thickness()-grout_width()-floor_prep_thickness();

        // lower back wall
        translate([wall_prep_thickness(), 0, 0]) {
            tile_grid(width=back_wall_width,height=-lower_surround_height,first_tile_width=back_wall_first_tile_width());
        }

        // back wall shelf
        translate([wall_prep_thickness()+tile_thickness()+grout_width(), -tile_thickness(), grout_width()]) {
            rotate([-90,0,0]) tile_grid(width=back_wall_rough_width()-2*(wall_prep_thickness()+tile_thickness()+grout_width()),height=back_wall_shelf_rough_depth()-grout_width(),first_tile_width=back_wall_first_tile_width()-tile_thickness()-grout_width());
        }

        lower_side_wall_width=left_wall_rough_width()-back_wall_shelf_rough_depth()-knee_rough_thickness()-2*(wall_prep_thickness()+tile_thickness()+grout_width());
        pre_accent_width=accent_x_offset-back_wall_shelf_rough_depth();
        post_accent_width=lower_side_wall_width-pre_accent_width-accent_width()-grout_width();

        // lower left wall
        translate([wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
            rotate([0,0,90]) translate([-pre_accent_width,0,0]) tile_grid(width=pre_accent_width,height=-lower_surround_height);
            translate([0, -pre_accent_width-accent_width()-grout_width(), 0]) {
                rotate([0,0,90]) tile_grid(width=-post_accent_width,height=-lower_surround_height);
            }
        }

        // lower right wall
        translate([back_wall_rough_width()-wall_prep_thickness(), -(tile_thickness()+grout_width()), 0]) {
            rotate([0,0,-90]) translate([pre_accent_width,0,0]) tile_grid(width=-pre_accent_width,height=-lower_surround_height);
            translate([0, -pre_accent_width-accent_width()-grout_width(), 0]) {
                rotate([0,0,-90]) tile_grid(width=post_accent_width,height=-lower_surround_height);
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
        translate([left_wall_knee_rough_width()+wall_prep_thickness(), -left_wall_rough_width()-drywall_thickness()+back_wall_shelf_rough_depth()+wall_prep_thickness(), 0]) {
            rotate([0,0,90]) tile_grid(width=endcap_width,height=-lower_surround_height);
        }
        translate([wall_prep_thickness()+tile_thickness()+grout_width(), -left_wall_rough_width()-drywall_thickness()+back_wall_shelf_rough_depth()+wall_prep_thickness(), 0]) {
            width=left_wall_knee_rough_width()-grout_width();
            twidth=tile_width()>=tile_height()?tile_width():tile_height();
            theight=tile_width()>=tile_height()?tile_height():tile_width();
            rotate([-90,0,0]) tile_grid(width=width,height=endcap_width,tile_width=twidth,tile_height=theight);
        }


        // right knee wall
        translate([back_wall_rough_width()-wall_prep_thickness(), -lower_side_wall_width-2*(grout_width()+tile_thickness()), 0]) {
            width=right_wall_knee_rough_width()-grout_width();
            translate([-width,0,0]) {
                rotate([0,0,-180]) tile_grid(width=-width,height=-lower_surround_height);
            }
        }
        translate([back_wall_rough_width()-right_wall_knee_rough_width()-wall_prep_thickness(), -left_wall_rough_width()-drywall_thickness()+back_wall_shelf_rough_depth()+wall_prep_thickness()+endcap_width, 0]) {
            rotate([0,0,-90]) tile_grid(width=endcap_width,height=-lower_surround_height);
        }
        translate([back_wall_rough_width()-wall_prep_thickness()-tile_thickness()-grout_width(), -left_wall_rough_width()-drywall_thickness()+back_wall_shelf_rough_depth()+wall_prep_thickness(), 0]) {
            width=right_wall_knee_rough_width()-grout_width();
            translate([-width,0,0]) {
                twidth=tile_width()>=tile_height()?tile_width():tile_height();
                theight=tile_width()>=tile_height()?tile_height():tile_width();
                rotate([-90,0,0]) tile_grid(width=width,height=endcap_width,tile_width=twidth,tile_height=theight);
            }
        }
    }

    // upper surround
    translate([0, -wall_prep_thickness(), knee_rough_height()+wall_prep_thickness()]) {

        upper_surround_height = right_wall_rough_height()-(knee_rough_height()+wall_prep_thickness());
        upper_side_wall_width=left_wall_rough_width()+drywall_thickness()-(wall_prep_thickness()+tile_thickness()+grout_width());
        pre_accent_width=accent_x_offset;
        post_accent_width=upper_side_wall_width-pre_accent_width-accent_width()-grout_width();

        // upper back wall
        translate([wall_prep_thickness(), 0, 0]) {
            tile_grid(width=back_wall_width,height=upper_surround_height,first_tile_width=back_wall_first_tile_width());
        }

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
            translate([0, -pre_accent_width-accent_width()-grout_width(), 0]) {
                rotate([0,0,-90]) tile_grid(width=post_accent_width,height=upper_surround_height);
            }
        }
    }

    // left wall accent
    translate([wall_prep_thickness(), -wall_prep_thickness()-tile_thickness()-grout_width()-accent_x_offset-accent_width(), floor_prep_thickness()]) {
        rotate([0,0,90]) {
            accent_tile(width=accent_width(),length=left_wall_rough_height());
        }
    }

    // right wall accent
    translate([back_wall_rough_width()-wall_prep_thickness(), -wall_prep_thickness()-tile_thickness()-grout_width()-accent_x_offset, floor_prep_thickness()]) {
        rotate([0,0,-90]) {
            accent_tile(width=accent_width(),length=right_wall_rough_height());
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
                            tile_grid(width=floor_row_width(),height=floor_depth,first_tile_width=floor_first_tile_width(),tile_width=floor_tile_width(),tile_height=floor_tile_height(),tile_thickness=floor_tile_thickness());
                        }
                    }
                }
            }
        }
    }
}

/*
 *
 * y1 -    B
 *        /|
 * y2 -  / C
 * y3 - A /
 *      |/
 * y4 - D
 *
 *      |  |
 *
 *      x  x
 *      1  2
 */

module shower_ceiling(thickness=ceiling_thickness()) {
    rotate([90,0,0]) {
        linear_extrude(height = right_wall_rough_width()) {
            y1 = right_wall_rough_height();
            y2 = y1-thickness;
            y3 = left_wall_rough_height();
            y4 = y3-thickness;

            x1 = 0;
            x2 = back_wall_rough_width();

            A = [ x1, y3];
            B = [ x2, y1];
            C = [ x2, y2];
            D = [ x1, y4];

            polygon( points = [ A, B, C, D]);
        }
    }
}

module shower_cubby(width,height,first_tile_width,first_tile_height,depth=inches(3.5),omit_back_wall=false) {
    adjusted_first_tile_height=min(tile_height(),first_tile_height+tile_thickness()+(height<=(first_tile_height+grout_width())?tile_thickness():0));

    // shelf
    translate([grout_width(),-tile_thickness(),grout_width()]) {
        rotate([-90,0,0]) tile_grid(width=width,height=depth-grout_width(),first_tile_width=first_tile_width-grout_width());
    }

    // ceiling
    translate([grout_width(),depth-tile_thickness()-grout_width(),height+tile_thickness()]) {
        rotate([90,0,0]) tile_grid(width=width-2*grout_width(),height=depth-tile_thickness()-2*grout_width(),first_tile_width=first_tile_width-grout_width());
    }

    if (!omit_back_wall) {
        // back
        translate([-tile_thickness(),depth,grout_width()]) {
            if (false) {
                tile_grid(width=width+2*tile_thickness(),height=height+tile_thickness()-grout_width(),first_tile_width=first_tile_width+tile_thickness(),first_tile_height=adjusted_first_tile_height);
            } else {
                accent_tile(width=width+2*tile_thickness(),length=height+tile_thickness());
            }
        }
    }

    // left
    translate([-tile_thickness(),grout_width(),grout_width()]) {
        rotate([0,0,90]) tile_grid(width=depth-tile_thickness()-2*grout_width(),height=height+tile_thickness()-grout_width(),first_tile_height=adjusted_first_tile_height);
    }

    // right
    translate([width+tile_thickness(),depth-tile_thickness()-grout_width(),grout_width()]) {
        rotate([0,0,-90]) tile_grid(width=depth-tile_thickness()-2*grout_width(),height=height+tile_thickness()-grout_width(),first_tile_height=adjusted_first_tile_height);
    }
}

module shower() {
    union() {
        difference() {
            shower_tile_surround();

            translate([0,0,feet(3)-ceiling_thickness()]) shower_ceiling(thickness=feet(3));

            translate([window_jamb_opening_right_offset(),-feet(1),window_sill_height()]) {
                cube([window_jamb_opening_width(),feet(1),window_jamb_opening_height()]);
            }

            translate([window_jamb_opening_right_offset(),-feet(1),foot_cubby_height()]) {
                cube([window_jamb_opening_width(),feet(1),window_jamb_opening_height()]);
            }

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
        color([.247, .165, .078, ceiling_alpha]) shower_ceiling();

        // window opening
        translate([window_jamb_opening_right_offset(),-wall_prep_thickness(),window_sill_height()]) {
            w=(window_jamb_opening_right_offset()-wall_prep_thickness()-back_wall_first_tile_width())/(tile_width()+grout_width());
            h=(window_sill_height()-floor_prep_thickness()-back_wall_first_tile_height())/(tile_height()+grout_width());
            first_tile_height=true&&window_jamb_opening_height()<=tile_height()?0:tile_height()-(tile_height()+grout_width())*(h-floor(h))+grout_width();
            shower_cubby(width=window_jamb_opening_width(),height=window_jamb_opening_height(),
                    first_tile_width=tile_width()-(tile_width()+grout_width())*(w-floor(w))+grout_width(),
                    first_tile_height=first_tile_height,
                    depth=window_sill_depth(),omit_back_wall=true);
        }

        // foot cubby
        translate([window_jamb_opening_right_offset(),-wall_prep_thickness()-foot_cubby_depth(),foot_cubby_height()]) {
            w=(window_jamb_opening_right_offset()-wall_prep_thickness()-back_wall_first_tile_width())/(tile_width()+grout_width());
            h=(foot_cubby_height()-floor_prep_thickness()-back_wall_first_tile_height())/(tile_height()+grout_width());
            first_tile_height=true&&window_jamb_opening_height()<=tile_height()?0:tile_height()-(tile_height()+grout_width())*(h-floor(h))+grout_width();
            shower_cubby(width=window_jamb_opening_width(),height=window_jamb_opening_height(),
                    first_tile_width=tile_width()-(tile_width()+grout_width())*(w-floor(w))+grout_width(),
                    first_tile_height=first_tile_height,
                    depth=foot_cubby_depth());
        }

        color([.9, .9, .9, shower_bar_alpha]) {
            union() {
                translate([wall_prep_thickness()+tile_thickness()+bar_standoff(),-bar_y_offset_rough_center(),bar_z_offset()]) {
                    cylinder(h=bar_height(),d=bar_diameter(),center=false);
                }
                translate([back_wall_rough_width()-(wall_prep_thickness()+tile_thickness()+bar_standoff()),-bar_y_offset_rough_center(),bar_z_offset()]) {
                    cylinder(h=bar_height(),d=bar_diameter(),center=false);
                }
            }
        }

        color("Tan",stud_alpha) {
            difference() {
                translate([-inches(5.5)-inches(3.5),0,0]) {
                    cube([back_wall_rough_width()+inches(5.5)+inches(3.5)+feet(1),inches(5.5),right_wall_rough_height()]);
                }
                translate([window_jamb_opening_left_offset()-tile_thickness()-wall_prep_thickness(),-inches(1),window_sill_height()-wall_prep_thickness()]) {
                    cube([window_jamb_opening_width()+2*(tile_thickness()+wall_prep_thickness()),inches(7.5),window_jamb_opening_height()+tile_thickness()+2*wall_prep_thickness()]);
                }
                translate([inches(1.5),-inches(1),-inches(1)]) {
                    cube([back_wall_rough_width()-2*inches(1.5),inches(2)+inches(5.5),knee_rough_height()-inches(1.5)+inches(1)]);
                }
            }
            translate([0,-back_wall_shelf_rough_depth(),0]) {
                difference() {
                    cube([back_wall_rough_width(),back_wall_shelf_rough_depth(),knee_rough_height()]);
                    translate([window_jamb_opening_left_offset()-tile_thickness()-wall_prep_thickness(),-inches(1),foot_cubby_height()-wall_prep_thickness()]) {
                        cube([window_jamb_opening_width()+2*(tile_thickness()+wall_prep_thickness()),inches(2)+back_wall_shelf_rough_depth(),window_jamb_opening_height()+tile_thickness()+2*wall_prep_thickness()]);
                    }
                }
            }

            translate([0,-left_wall_rough_width(),0]) {
                translate([-inches(3.5)-left_wall_shim_thickness(),0,0]) {
                    cube([inches(3.5),left_wall_rough_width(),left_wall_rough_height()]);
                    translate([-inches(5.5),-feet(1),0]) {
                        cube([inches(5.5),left_wall_rough_width()+feet(1),left_wall_rough_height()]);
                    }
                }
                cube([left_wall_knee_rough_width(),knee_rough_thickness(),knee_rough_height()]);
            }
            translate([back_wall_rough_width(),-right_wall_rough_width(),0]) {
                cube([inches(5.5),right_wall_rough_width(),right_wall_rough_height()]);
                translate([-right_wall_knee_rough_width(),right_wall_rough_width()-left_wall_rough_width(),0]) {
                    cube([right_wall_knee_rough_width(),knee_rough_thickness(),knee_rough_height()]);
                }
            }
        }

        color([0.66,0.7,1.0],drywall_alpha) union() {
            translate([0,-left_wall_rough_width()-drywall_thickness(),0]) {
                cube([left_wall_knee_rough_width()+wall_prep_thickness()-grout_width(),drywall_thickness(),knee_rough_height()+wall_prep_thickness()-grout_width()]);
            }
            translate([-inches(3.5),-left_wall_rough_width()-drywall_thickness(),0]) {
                cube([inches(3.5)+wall_prep_thickness()-grout_width(),drywall_thickness(),left_wall_rough_height()]);
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
            translate([back_wall_rough_width(),-right_wall_rough_width(),0]) {
                cube([inches(5.5),right_wall_rough_width(),right_wall_rough_height()]);
                translate([-right_wall_knee_rough_width(),right_wall_rough_width()-left_wall_rough_width(),0]) {
                    cube([right_wall_knee_rough_width(),knee_rough_thickness(),knee_rough_height()]);
                }
            }
*/
        }
    }
}

// Standalone rendering
shower();
