use <math.scad>;
use <railing.scad>;

$fn = 12;

function _echo(x,s) = [x, search([str(s)], [])][0];
function _assert(m,x,v) = x?v:_echo(v, str(m));
function _value(n,v) = _echo(v, str(n," = ",v));
function _func(n,a) = _echo(undef, str(n,"(",_args(a),")"));
function _args(a,i=0,s="") = i>=len(a)?s:_args(a,i+2,i==0?str(a[0],"=",a[1]):str(s,", ",a[i],"=",a[i+1]));

function feet( x) = inches( x) * 12;
function inches( x) = x;

function fireplace_wall_window_offset_drywall_to_frame() = inches(3.5);
function fireplace_wall_window_width() = inches(41);
function window_trim_extension_from_frame() = inches(3.5-0.75);
function lower_subfloor_height() = 0;
function upper_subfloor_height() = lower_subfloor_height() + inches(121.5);
function fireplace_wall_width() = fireplace_wall_total_width() - fireplace_wall_window_offset_drywall_to_frame() - fireplace_wall_window_width() - window_trim_extension_from_frame();

function upper_ceiling_high_point() = inches(210);
function lower_ceiling_height() = inches(107);
function fireplace_wall_high_window_top() = inches(191.75);

function listening_center_from_long_wall() = inches(104.5);
function listening_center_from_fireplace_drywall() = inches(164);

function stairwell_width() = inches(85);
function stairwell_length() = inches(108);
function stairwell_to_fireplace_return() = inches(57.5);
function stairwell_to_master_wall() = inches(72.5);
function stairwell_landing_subfloor_to_upper_subfloor() = inches(53.5);
function stairwell_landing_width() = inches(87);
function stairwell_landing_depth() = inches(48);

function floor_thickness() = inches(13.5); // subfloor to ceiling

function fireplace_return_to_master_interior_length() = inches(37.5);


/*
posts 4" from sides of stairwell
8x8
4" from back edge of post to back edge of stair (back is the side toward master)

82.5H 68.5W (inside)

210 high point
191 top of window (inside)
74.5H 39.25W (inside)
3.5 to outside of window frame along fireplace wall


37.5 return to master
        12 between wall and master door trim

down:
11.5 return to outside of window frame
46.5 return to bedroom (door) wall
*/

function exterior_wall_thickness() = inches(7.5);
function interior_wall_thickness() = inches(6.5);

function window_wall_interior_length() = inches(389);
function window_wall_length() = window_wall_interior_length() + 2*exterior_wall_thickness();

function fireplace_wall_interior_length() = inches(161.25);
function fireplace_wall_length() = fireplace_wall_interior_length() + exterior_wall_thickness();


module window_cutout(frame_width, frame_height, wall_thickness) {
    translate([0, -inches(1), 0]) {
        cube([frame_width, wall_thickness+inches(2), frame_height]);
    }
}

module door_cutout(frame_width, frame_height, wall_thickness) {
    translate([0, 0, -inches(1)]) {
        window_cutout(frame_width, frame_height+inches(1), wall_thickness);
    }
}

function upper_window_frame_height() = inches(76);
function middle_window_frame_height() = inches(84);
function lower_window_frame_height() = inches(65);

module window_wall() {
    color("lightgray")
    difference() {
        rotate([90, 0, -90]) {
            translate([-exterior_wall_thickness(), 0, -window_wall_length()]) {
                linear_extrude(window_wall_length()) {
                    polygon([[0, 0],
                            [0, upper_subfloor_height()+upper_ceiling_high_point()+exterior_wall_thickness()*ceiling_slope()],
                            [exterior_wall_thickness(), upper_subfloor_height()+upper_ceiling_high_point()],
                            [exterior_wall_thickness(),0]]);
                }
            }
        }

        window_frame_width = inches(70);
        rightmost_window_frame_x_offset = window_wall_length() - exterior_wall_thickness() - inches(7) - window_frame_width;
        window_x_offset_step = - inches(7) - window_frame_width;

        upper_window_z_offset = upper_subfloor_height() + feet(16) - upper_window_frame_height();
        for (i = [0:4]) {
            translate([rightmost_window_frame_x_offset + i * window_x_offset_step, 0, upper_window_z_offset]) {
                window_cutout(window_frame_width, upper_window_frame_height(), exterior_wall_thickness());
            }
        }

        middle_window_z_offset = upper_subfloor_height() + feet(8) - middle_window_frame_height();
        for (i = [0:4]) {
            translate([rightmost_window_frame_x_offset + i * window_x_offset_step, 0, middle_window_z_offset]) {
                window_cutout(window_frame_width, middle_window_frame_height(), exterior_wall_thickness());
            }
        }

        lower_window_z_offset = inches(80) - lower_window_frame_height();
        for (i = [0:4]) {
            translate([rightmost_window_frame_x_offset + i * window_x_offset_step, 0, lower_window_z_offset]) {
                window_cutout(window_frame_width, lower_window_frame_height(), exterior_wall_thickness());
            }
        }
    }
}

function fireplace_wall_window_frame_width() = inches(41);
function fireplace_wall_window_frame_x_offset() = inches(3.5);
function door_trim_width() = inches(3.5);
function window_trim_width() = inches(3.5);
function window_frame_thickness() = inches(0.75);
function window_trim_offset() = window_frame_thickness() - inches(0.25);
function upper_fireplace_x_offset() = fireplace_wall_window_frame_x_offset() + fireplace_wall_window_frame_width() - window_trim_offset() + window_trim_width();
function lower_fireplace_x_offset() = upper_fireplace_x_offset();

echo(upper_fireplace_x_offset=upper_fireplace_x_offset());

function upper_fireplace_width() = fireplace_wall_interior_length() - upper_fireplace_x_offset() + upper_fireplace_return_buildout();
function lower_fireplace_width() = fireplace_wall_interior_length() - upper_fireplace_x_offset() + lower_fireplace_return_buildout();

echo(upper_fireplace_width=upper_fireplace_width()/2);

function ceiling_slope() = 3/12.0;
function stone_thickness() = inches(2.5);

module fireplace_wall() {
    color("lightgray")
    difference() {
        rotate([90, 0, 0]) {
            translate([0, 0, -exterior_wall_thickness()]) {
                linear_extrude(exterior_wall_thickness()) {
                    polygon([[0, 0],
                            [0, upper_subfloor_height()+upper_ceiling_high_point()+exterior_wall_thickness()*ceiling_slope()],
                            [fireplace_wall_length(), upper_subfloor_height()+upper_ceiling_high_point()-fireplace_wall_interior_length()*ceiling_slope()],
                            [fireplace_wall_length(), 0]]);
                }
            }
        }

        window_frame_width = fireplace_wall_window_frame_width();
        window_frame_x_offset = exterior_wall_thickness() + fireplace_wall_window_frame_x_offset();

        upper_window_z_offset = upper_subfloor_height() + feet(16) - upper_window_frame_height();
        translate([window_frame_x_offset, 0, upper_window_z_offset]) {
            window_cutout(window_frame_width, upper_window_frame_height(), exterior_wall_thickness());
        }

        middle_window_z_offset = upper_subfloor_height() + feet(8) - middle_window_frame_height();
        translate([window_frame_x_offset, 0, middle_window_z_offset]) {
                window_cutout(window_frame_width, middle_window_frame_height(), exterior_wall_thickness());
            }

        lower_window_z_offset = inches(80) - lower_window_frame_height();
        translate([window_frame_x_offset, 0, lower_window_z_offset]) {
                window_cutout(window_frame_width, lower_window_frame_height(), exterior_wall_thickness());
            }
    }
}

function master_wall_height() = inches(176.25);
function master_wall_length() = exterior_wall_thickness() + inches(300);
function entrance_hall_width() = inches(66.5);

module lower_fireplace_return_window_cutout(thickness=exterior_wall_thickness()) {
    frame_height = inches(46);
    lower_window_z_offset = inches(80) - frame_height;
    translate([inches(12), 0, lower_window_z_offset]) {
        window_cutout(inches(29), frame_height, thickness);
    }
}

module fireplace_return_to_master_wall() {
    color("lightgray")
    difference() {
        rotate([90, 0, 0]) {
            translate([0, 0, -exterior_wall_thickness()]) {
                linear_extrude(exterior_wall_thickness()) {
                    polygon([[0, 0],
                            [0, upper_subfloor_height()+master_wall_height()+fireplace_return_to_master_interior_length()*ceiling_slope()],
                            [fireplace_return_to_master_interior_length()+exterior_wall_thickness(), upper_subfloor_height()+master_wall_height()-exterior_wall_thickness()*ceiling_slope()],
                            [fireplace_return_to_master_interior_length()+exterior_wall_thickness(), 0]]);
                }
            }
        }
        lower_fireplace_return_window_cutout();
    }
}

module master_wall() {
    color("lightgray")
    difference() {
        rotate([90, 0, 90]) {
            linear_extrude(master_wall_length()) {
                polygon([[0, -inches(1)],
                        [0, master_wall_height()],
                        [interior_wall_thickness(), master_wall_height()-interior_wall_thickness()*ceiling_slope()],
                        [interior_wall_thickness(), -inches(1)]]);
            }
        }
        translate([exterior_wall_thickness()+inches(12)+door_trim_width(),0,0]) {
            door_cutout(inches(36),inches(80),interior_wall_thickness());
        }
    }
    translate([exterior_wall_thickness()+inches(12)+door_trim_width(),0,0]) {
        trim_thickness = inches(0.75);
        translate([0,-trim_thickness,0]) {
            color([0.3,0.3,0.3]) {
                union() {
                    translate([-door_trim_width(),0,0]) {
                        cube([door_trim_width(),trim_thickness,inches(80)+door_trim_width()]);
                    }
                    translate([-door_trim_width(),0,inches(80)]) {
                        cube([inches(36)+2*door_trim_width(),trim_thickness,door_trim_width()]);
                    }
                    translate([inches(36),0,0]) {
                        cube([door_trim_width(),trim_thickness,inches(80)+door_trim_width()]);
                    }
                }
            }
        }
    }
}

module walls() {
    union() {
        rotate([0, 0, 90]) {
            translate([-(window_wall_length()-exterior_wall_thickness()), 0, 0]) {
                window_wall();
            }
        }
        translate([-exterior_wall_thickness(), 0, 0]) {
            fireplace_wall();
        }

        translate([fireplace_wall_interior_length(), 0, 0]) {
            rotate([0, 0, 90]) {
                fireplace_return_to_master_wall();
            }
        }
        translate([fireplace_wall_interior_length()-exterior_wall_thickness(), fireplace_return_to_master_interior_length(), upper_subfloor_height()]) {
            master_wall();
        }

        translate([fireplace_wall_interior_length()+stairwell_to_fireplace_return()-inches(4)-inches(8),
                fireplace_return_to_master_interior_length()-stairwell_to_master_wall()-inches(4),
                upper_subfloor_height()]) {
            color(walnut()) cube([inches(8),inches(8),inches(200)]);

            translate([inches(4),0,inches(3.5)]) {
                rotate([0,0,-90]) {
                    railing(balusters_load([99.5, 31.5, 0.75, 0.75, 3, 3.375, 26953, -1, 0.0688432, [[1, 2], [5, 4], [7, 9], [11, 10], [12, 15], [16, 14], [19, 17], [20, 22], [25, 23], [28, 30], [29, 26], [34, 31], [36, 35], [40, 38], [41, 42], [43, 46], [48, 45], [52, 49], [54, 53], [57, 55], [60, 63], [62, 60], [65, 68], [70, 69], [73, 72], [74, 76], [76, 79], [81, 78], [84, 82], [85, 87], [89, 88], [93, 90], [95, 98], [96, 94], [100, 101], [104, 106], [107, 108], [110, 111], [112, 115], [116, 113], [118, 119], [120, 122], [124, 125], [128, 126], [129, 130]]]),left_post=false,right_post=false,alpha=1);
                }
            }

            translate([inches(8),inches(4),inches(3.5)]) {
                railing(balusters_load([92.75, 31.5, 0.75, 0.75, 3, 3.375, 760766, -1, 0.0499195, [[2, 1], [4, 6], [7, 10], [12, 9], [15, 14], [19, 17], [21, 20], [25, 23], [26, 27], [30, 28], [32, 34], [35, 32], [39, 37], [41, 42], [44, 47], [48, 45], [50, 51], [52, 54], [55, 57], [58, 55], [61, 58], [62, 63], [66, 64], [68, 71], [69, 66], [72, 74], [77, 76], [79, 82], [80, 79], [82, 85], [87, 88], [90, 92], [93, 91], [95, 97], [99, 100], [102, 105], [106, 109], [109, 107], [112, 111], [114, 115], [119, 116], [121, 120]]]),left_post=false,right_post=false,alpha=1);
            }
        }
        translate([fireplace_wall_interior_length()+stairwell_to_fireplace_return()+stairwell_width()+inches(4),
                fireplace_return_to_master_interior_length()-stairwell_to_master_wall()-inches(4),
                upper_subfloor_height()]) {
            color(walnut()) cube([inches(8),inches(8),inches(200)]);

            translate([inches(4),0,inches(3.5)]) {
                rotate([0,0,-90]) {
                    railing(balusters_load([99, 31.5, 0.75, 0.75, 3, 3.375, 96679, -1, 0.442657, [[3, 1], [4, 7], [6, 4], [8, 10], [12, 11], [14, 15], [19, 16], [20, 23], [21, 19], [23, 26], [28, 29], [31, 34], [34, 31], [36, 37], [39, 41], [44, 42], [45, 47], [49, 52], [50, 48], [53, 54], [56, 58], [60, 62], [65, 64], [67, 70], [71, 68], [72, 74], [76, 75], [80, 77], [82, 81], [84, 86], [88, 85], [89, 88], [90, 92], [94, 95], [97, 100], [101, 104], [105, 102], [108, 105], [111, 110], [116, 114], [118, 121], [119, 117], [124, 122], [125, 126], [130, 128]]]),left_post=false,right_post=false,alpha=1);
                }
            }
        }
        translate([fireplace_wall_interior_length()+stairwell_to_fireplace_return()+stairwell_width()+inches(4),
                fireplace_return_to_master_interior_length()-stairwell_to_master_wall()-stairwell_length()-inches(4),
                upper_subfloor_height()]) {
            color(walnut()) cube([inches(8),inches(8),inches(200)]);
        }
        translate([fireplace_wall_interior_length()+stairwell_to_fireplace_return()-inches(4)-inches(8),
                fireplace_return_to_master_interior_length()-stairwell_to_master_wall()-stairwell_length()-inches(4),
                upper_subfloor_height()]) {
            color(walnut()) cube([inches(8),inches(8),inches(42)]);
        }
        translate([fireplace_wall_interior_length()+stairwell_to_fireplace_return()+inches(40.5),
                fireplace_return_to_master_interior_length()-stairwell_to_master_wall()-stairwell_length()-inches(4),
                upper_subfloor_height()]) {
            color(walnut()) cube([inches(8),inches(8),inches(42)]);

            translate([inches(8),inches(4),inches(3.5)]) {
                railing(balusters_load([40.25, 31.5, 0.75, 0.75, 3, 3.375, 527737, -1, 0.225115, [[3, 2], [5, 7], [9, 10], [14, 12], [15, 17], [18, 16], [21, 19], [25, 22], [26, 27], [31, 29], [33, 35], [34, 32], [37, 38], [41, 40], [42, 44], [46, 47], [49, 51]]]),left_post=false,right_post=false,alpha=1);
            }
        }

/*
return 46.5
other side of hall 81.5
        213 from origin corner

68.75 to top of landing
9.5 landing thickness
91 landing width
5.75 landing extension beyond stringer
54.25 landing depth
24"
9 3/8 : 12 slope

stringers: 10"x2"
treads: 12"x1.75"

first tread 5 5/8" under
others 5 7/8"

stairs 40.5" incl stringers
*/

        translate([inches(213),inches(46.5)-inches(81.5), 0]) {
            color("lightgray") {
                cube([inches(91),interior_wall_thickness(),inches(108)]);
                translate([inches(1.5),interior_wall_thickness(),0]) {
                    cube([interior_wall_thickness(),inches(81.5)-interior_wall_thickness(),inches(108)]);
                }
                translate([inches(91),-inches(166),0]) {
                    cube([interior_wall_thickness(),inches(166),inches(108)]);
                }
            }
            translate([0,-inches(54.25),inches(68.75)]) {
                color(lightwalnut()) {
                    translate([0,0,-inches(1.5)]) {
                        cube([inches(91),inches(54.25),inches(1.5)]);
                    }
                }
                translate([0,0,-inches(9.5)]) {
                    color(walnut()) cube([inches(91),inches(54.25),inches(8)]);
                }
                translate([inches(5.75)+inches(0.001),inches(3/4),0]) {
                    stringer();
                    translate([inches(40.5)-inches(2),0,0]) {
                        stringer();
                        translate([inches(0.5),0,0]) {
                            color(walnut()) cube([inches(8),inches(8),inches(38)]);
                        }
                    }
                }
            }
            translate([0,-inches(54.25)-inches(72.375),0]) {
                translate([inches(91)-inches(0.001),inches(3/4),0]) {
                    difference() {
                        rotate([0,0,180]) {
                            stringer();
                            translate([inches(40.5)-inches(2),0,0]) {
                                stringer();
                            }
                        }
                        translate([-inches(40.5)-inches(1),inches(70.5),inches(68.75)-inches(0.001)]) {
                            cube([inches(42.5),inches(3),inches(3)]);
                        }
                    }
                }
            }

            if (false) {
                translate([0,-inches(54.25),inches(68.75)]) {
                    color(lightwalnut()) {
                        cube([inches(3),inches(54.25),inches(1)]);
                        translate([0,0,0]) {
                            cube([inches(5.75),inches(3),inches(1)]);
                        }
                    }
                }
                translate([0,-inches(88.5),inches(108)-inches(2.5)]) {
                    color(lightwalnut()) {
                        cube([inches(3),inches(88.5),inches(1)]);
                        translate([0,0,0]) {
                            cube([inches(5.75),inches(3),inches(1)]);
                        }
                    }
                }

                topslots = concat(
                        [[inches(5.75)-inches(2.25),-inches(88.5)+inches(1.5),inches(108)-inches(2.5)]],
                        [for (s=railing_slots(inches(88.5)-inches(54.25)-inches(0.75)+inches(6),[inches(3),inches(3.75)])) [inches(1.5),-inches(88.5)+inches(1.5)+inches(0.75)+s[1],inches(108)-inches(2.5)]]);
                first_bottomslots = concat(
                        [[inches(5.75)-inches(0.75),-inches(54.25)+inches(1.5),inches(68.75)+inches(1)]],
                        [for (i=[0:3]) [inches(5.75)-(i+2)*inches(0.75),-inches(54.25)+inches(1.5),inches(68.75)+inches(1)]]);
                bottomslots = concat(first_bottomslots,
                        [for (i=[0:len(topslots)-len(first_bottomslots)-1]) [inches(1.5),-inches(54.25)+inches(1.5)+(i+0.5)*inches(0.75),inches(68.75)+inches(1)]]);
                echo(t=len(topslots));
                echo(b=len(bottomslots));
                o=inches(3/8);
                mapping=[ [0, [0,-o,0]],
                          [2, [0,-o,0]],
                          [1, [0,o,0]],
                          [3, [0,o,0]],
                          [4, [0,-o,0]],
                          [5, [0,0,0]],
                          [7, [-o,0,0]],
                          [6, [o,0,0]],
                          [8, [-o,0,0]],
                          [10, [-o,0,0]],
                          [9, [o,0,0]],
                          [11, [-o,0,0]],
                          [12, [-o,0,0]] ];
                for (i=[0:len(bottomslots)-1]) {
                    color([0.4,0.4,0.4]) {
                        rod(inches(3/8), bottomslots[i]+mapping[i][1], topslots[mapping[i][0]], extension=inches(0.75));
                    }
                }
            } else if (false) {
                translate([inches(5.75)-inches(3)-inches(0.001),-inches(88.5),inches(108)-inches(1)]) {
                    color(lightwalnut()) cube([inches(3),inches(88.5),inches(1.5)]);
                }
                translate([inches(5.75)-inches(3),-inches(54.25)+inches(8.25),inches(68.75)+inches(3.5)]) {
                    color(lightwalnut()) cube([inches(3),inches(54.25),inches(1.5)]);
                }
                translate([inches(5.75)-inches(3),-inches(54.25)+inches(8.25)-inches(1.5),inches(68.75)]) {
                    color(lightwalnut()) cube([inches(3),inches(1.5),inches(6.75)]);
                }
                translate([inches(5.75)-inches(3)-inches(0.0001),-inches(54.25)+inches(3/4),inches(68.75)]) {
//                    difference() {
                        union() {
                            rotate([0,-atan((9+3/8)/12),-90]) {
                                translate([-inches(1.75),0,inches(10)-inches(1.5)]) {
                                    color(lightwalnut()) cube([inches(90),inches(3),inches(1.5)]);
                                }
                            }
                        }
/*
                        translate([-inches(1),inches(7.5),0]) {
                            color(lightwalnut()) cube([inches(5),inches(10),inches(10)]);
                        }
                    }
*/
                }
                translate([inches(5.75)+inches(40.5)+inches(0.0001),-inches(54.25)+inches(3/4),inches(68.75)]) {
                    difference() {
                        union() {
                            rotate([0,-atan((9+3/8)/12),-90]) {
                                translate([inches(6),0,inches(10)-inches(1.5)]) {
                                    color(lightwalnut()) cube([inches(90),inches(1.5),inches(1.5)]);
                                }
                            }
                        }
                        translate([-inches(1),-inches(0.0001),inches(10)-inches(5)]) {
                            color(lightwalnut()) cube([inches(3.5),inches(10),inches(10)]);
                        }
                    }
                    translate([-inches(1.5)/2,0,0]) {
                        difference() {
                            union() {
                                rotate([0,-atan((9+3/8)/12),-90]) {
                                    translate([inches(17),0,inches(10)+inches(24)-inches(1.5)]) {
                                        color(lightwalnut()) cube([inches(90),inches(3),inches(1.5)]);
                                    }
                                }
                            }
                            translate([-inches(1),-inches(3/4),inches(10)-inches(5)]) {
                                color(lightwalnut()) cube([inches(3.5),inches(10),inches(10)]);
                            }
                        }
                    }
                }
            } else {
                translate([0,-inches(54.25),inches(108)-inches(1.5)]) {
                    color(lightwalnut()) cube([inches(3),inches(54.25),inches(1.5)]);
                    color(lightwalnut()) cube([inches(5.75)-inches(0.001),inches(3),inches(1.5)]);
                }
                translate([inches(5.75)-inches(1.5),-inches(87.5),inches(108)-inches(1.5)]) {
                    color(lightwalnut()) cube([inches(1.5)-inches(0.001),inches(87.5)-inches(54.25)-inches(0.001),inches(1.5)]);
                }
                translate([0,-inches(54.25),inches(68.75)+inches(3.5)]) {
                    color(lightwalnut()) cube([inches(3),inches(54.25),inches(1.5)]);
                }
                translate([0,-inches(54.25),inches(68.75)+inches(3.5)]) {
                    color(lightwalnut()) cube([inches(5.75),inches(3),inches(1.5)]);
                }
                translate([inches(1.5),-inches(54.25)+inches(1.5),0]) {
                    color([0.4,0.4,0.4]) rod(diameter=inches(3/4),from=[0,0,inches(68.75)],to=[0,0,inches(108)]);
                }
                translate([inches(5.75)-inches(1.5)-inches(0.0001),-inches(54.25)+inches(3/4),inches(68.75)]) {
                    difference() {
                        union() {
                            rotate([0,-atan((9+3/8)/12),-90]) {
                                translate([-inches(1.75),0,inches(10)-inches(1.5)]) {
                                    color(lightwalnut()) cube([inches(90),inches(1.5),inches(1.5)]);
                                }
                            }
                        }
                        translate([-inches(1),-inches(3/4),inches(4)]) {
                            color(lightwalnut()) cube([inches(5),inches(10),inches(10)]);
                        }
                        translate([-inches(1),-inches(3/4)-inches(87.5)+inches(54.25)-inches(3),inches(108)-inches(3)-inches(68.75)]) {
                            color(lightwalnut()) cube([inches(5),inches(3),inches(10)]);
                        }
                    }
                }
                translate([inches(5.75)+inches(40.5)+inches(0.0001),-inches(54.25)+inches(3/4),inches(68.75)]) {
                    difference() {
                        union() {
                            rotate([0,-atan((9+3/8)/12),-90]) {
                                translate([inches(6),0,inches(10)-inches(1.5)]) {
                                    color(lightwalnut()) cube([inches(90),inches(1.5),inches(1.5)]);
                                }
                            }
                        }
                        translate([-inches(1),-inches(0.0001),inches(10)-inches(5)]) {
                            color(lightwalnut()) cube([inches(3.5),inches(10),inches(10)]);
                        }
                    }
                    translate([-inches(1.5)/2,0,0]) {
                        difference() {
                            union() {
                                rotate([0,-atan((9+3/8)/12),-90]) {
                                    translate([inches(17),0,inches(10)+inches(24)-inches(1.5)]) {
                                        color(lightwalnut()) cube([inches(90),inches(3),inches(1.5)]);
                                    }
                                }
                            }
                            translate([-inches(1),-inches(3/4),inches(10)-inches(5)]) {
                                color(lightwalnut()) cube([inches(3.5),inches(10),inches(10)]);
                            }
                        }
                    }
                }
            }
        }
    }
}

module stringer() {
    difference() {
        union() {
            rotate([0,-atan((9+3/8)/12),-90]) {
                translate([-inches(10),0,0]) {
                    color(walnut()) cube([inches(110),inches(2),inches(10)]);
                }
            }
        }
        union() {
            translate([-inches(1),inches(7.5),-inches(1)]) {
                color(walnut()) cube([inches(4),inches(20),inches(20)]);
            }
        }
    }
}

function railing_slots(l,gaps,v=[[0,0]]) =
        let(/*_f=_func("railing_slots",["l",l,"gaps",gaps,"v",v])*/,
            r=v[len(v)-1][1],
            g=gaps[len(v)%len(gaps)])
        (r+g)>=l ? v : railing_slots(l,gaps,concat(v,[[g,r+g]]));

I = [ [ 1, 0, 0 ],
      [ 0, 1, 0 ],
      [ 0, 0, 1 ] ];
function m3d24d(m, t=[]) = [concat(m[0],[t[0]]), concat(m[1],[t[1]]), concat(m[2],[t[2]]), [0,0,0,1]];

module rod(diameter, from, to, extension=0) {
//    _f=_func("rod",["diameter",diameter,"from",from,"to",to,"extension",extension]);
    // see https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d/476311#476311
    a = [0,0,1];
    origB = to-from;
    l = norm(origB);
    echo(l=l);
    b = origB/l;
    R = (a == b
         ? I
         : (norm(a-b) == 0
            ? -I
            : (let(v = cross(a, b),
                   v1 = v[0],
                   v2 = v[1],
                   v3 = v[2],
                   vx = [ [   0, -v3,  v2 ],
                          [  v3,   0, -v1 ],
                          [ -v2,  v1,   0 ] ])
               I + vx + vx*vx/(1 + a*b))));
    multmatrix(m3d24d(R,t=from)) {
        translate([0,0,-extension]) {
            cylinder(d=diameter, h=l+2*extension, center=false);
        }
    }
}

module floor() {
    floor_x_length = fireplace_wall_length()+feet(5)+stairwell_width()+feet(5);
    floor_y_length = window_wall_length()+fireplace_return_to_master_interior_length();
    difference() {
        translate([-exterior_wall_thickness(),-(floor_y_length-exterior_wall_thickness()-fireplace_return_to_master_interior_length()),upper_subfloor_height()-floor_thickness()]) {
            color([0.255, 0.255, 0.255]) {
                translate([0,0,inches(0.5)]) {
                    cube([floor_x_length,floor_y_length,floor_thickness()-inches(0.5)]);
                }
            }
            color("white") {
                cube([floor_x_length,floor_y_length,inches(0.5)]);
            }
        }
        color([0.7, 0.7, 0.7]) {
            translate([-exterior_wall_thickness()-inches(1), exterior_wall_thickness()-inches(1), upper_subfloor_height()-floor_thickness()-inches(1)]) {
                cube([fireplace_wall_length(),fireplace_return_to_master_interior_length()+2*inches(1),floor_thickness()+2*inches(1)]);
            }
            translate([fireplace_wall_interior_length()+stairwell_to_fireplace_return(),
                    fireplace_return_to_master_interior_length()-stairwell_to_master_wall()-stairwell_length(),
                    upper_subfloor_height()-floor_thickness()-inches(1)]) {
                cube([stairwell_width(),stairwell_length(),floor_thickness()+2*inches(1)]);
            }
        }
    }
}

module lower_floor() {
    floor_x_length = fireplace_wall_length()+feet(5)+stairwell_width()+feet(5);
    floor_y_length = window_wall_length()+fireplace_return_to_master_interior_length();
    color([0.355, 0.355, 0.355]) {
        translate([-exterior_wall_thickness(),-(floor_y_length-exterior_wall_thickness()-fireplace_return_to_master_interior_length()),-floor_thickness()]) {
            cube([floor_x_length,floor_y_length,floor_thickness()]);
        }
    }
}


function upper_tv_width() = inches(57.5);
function upper_tv_height() = inches(33);
function upper_tv_vertical_center() = inches(72);

function lower_tv_width() = inches(57.5);
function lower_tv_height() = inches(33);
function lower_tv_vertical_center() = inches(60);

function lower_tv_vertical_center() = lower_fireplace_unit_bottom()+lower_fireplace_unit_height()+inches(12)+lower_tv_height()/2;

echo(lower_tv_vertical_center=lower_tv_vertical_center());

function lower_fireplace_unit_thickness() = inches(0.5);
function lower_fireplace_unit_width() = inches(60);
function lower_fireplace_unit_height() = inches(21.5);
function lower_fireplace_unit_fire_width() = inches(45);
function lower_fireplace_unit_fire_height() = inches(12);
/*

function lower_fireplace_unit_thickness() = inches(0.5);
function lower_fireplace_unit_width() = inches(72);
function lower_fireplace_unit_height() = inches(21.5);
function lower_fireplace_unit_fire_width() = inches(66.5);
function lower_fireplace_unit_fire_height() = inches(12);
*/

function lower_fireplace_unit_bottom() = inches(12); //subwoofer_bench_height();

echo(lower_fireplace_unit_bottom=lower_fireplace_unit_bottom());

//function upper_tv_width() = inches(66);
//function upper_tv_height() = inches(38);
//function upper_tv_vertical_center() = inches(72);

    // A500 amp
    //cube([inches(19),inches(10),inches(4)]);

    // https://www.sonicelectronix.com/item_67755_1.5-Cu-Ft-Single-12-Sealed-MDF-Subwoofer-Enclosure-Belva-MDFS1215.html
    //cube([inches(16),inches(17),inches(13.5)]);

    // ventilation req. for fireplace (1 1000 + 1 500): 120 sq inches

function subwoofer_height() = inches(13);
function subwoofer_width() = inches(16);
function subwoofer_bottom_depth() = inches(15.5);
function subwoofer_top_depth() = inches(12);

module subwoofer() {
    union() {
        color([0.2,0.2,0.2]) {
            translate([subwoofer_width()/2,0,subwoofer_height()/2]) {
                rotate([90,0,0]) {
                    cylinder(d=inches(12),h=inches(1),center=true,$fn=60);
                }
            }
        }
        color([0.1,0.1,0.1]) {
            rotate([90,0,90]) {
                linear_extrude(subwoofer_width()) {
                    polygon([[0, 0],
                             [0, subwoofer_height()],
                             [subwoofer_top_depth(), subwoofer_height()],
                             [subwoofer_bottom_depth(), 0]]);
                }
            }
        }
    }
}

function walnut() = [0.247, 0.165, 0.078];
function lightwalnut() = [0.397, 0.315, 0.228];
function recess_depth() = inches(3.5);

// TV corners overhanging recesses
/*
function top_recess_y_offset() = inches(130);
function top_recess_height() = inches(32);
function top_recess_width() = inches(60);
function middle_recess_y_offset() = inches(63);
function middle_recess_height() = inches(54);
function middle_recess_width() = inches(36);
function bottom_recess_y_offset() = bench_top_height()+inches(6);
function bottom_recess_height() = inches(66);
function bottom_recess_width() = inches(36);
*/

echo(upper_tv_height=upper_tv_height());
echo(radiant_panel_height=radiant_panel_height());
echo(maybe_tv=bench_top_height()+2*upper_tv_height()+inches(8)-upper_tv_height());
echo(recess_band_height=recess_band_height());

function recess_band_height() = radiant_panel_height()+radiant_panel_margin()-inches(6);
function recess_band_offset() = upper_tv_vertical_center()-(radiant_panel_height()+radiant_panel_margin())/2-bench_top_height();
echo(recess_band_offset=recess_band_offset());
function recess_overlap() = inches(12);
function recess_width() = upper_fireplace_width()/2 + recess_overlap();
function upper_fireplace_return_width() = fireplace_return_to_master_interior_length()+buildout_depth();
function lower_fireplace_return_width() = upper_fireplace_return_width() + inches(8);
function upper_fireplace_return_recess_width() = upper_fireplace_return_width()-inches(6);

function top_recess_y_offset() = middle_recess_y_offset()+recess_band_offset();
function top_recess_height() = recess_band_height();
function top_recess_width() = recess_width();
function middle_recess_y_offset() = bottom_recess_y_offset()+recess_band_offset();
function middle_recess_height() = recess_band_height();
function middle_recess_width() = recess_width();
function bottom_recess_y_offset() = upper_tv_vertical_center()-bottom_recess_height()/2;
function bottom_recess_height() = recess_band_height();
function bottom_recess_width() = recess_width();

function bottomest_recess_y_offset() = bottom_recess_y_offset()-recess_band_offset();
function bottomest_recess_height() = recess_band_height();
function bottomest_recess_width() = recess_width();

function upper_fireplace_return_buildout() = recess_depth() + stone_thickness();
function lower_fireplace_return_buildout() = stone_thickness(); //+ recess_depth();

function cartridge_width() = inches(60);
function bench_opening_width() = cartridge_width()+2*inches(3);

function radiant_panel_width() = inches(63);
function radiant_panel_margin() = (bench_opening_width()-radiant_panel_width())/2;
function radiant_panel_thickness() = inches(2);
function radiant_panel_standoff() = inches(1);
function radiant_panel_recess() = buildout_depth();
function radiant_panel_height() = inches(25);

echo(upper_tv_vertical_center=upper_tv_vertical_center());

echo(radiant_panel_margin=radiant_panel_margin());

function buildout_depth() = inches(3.5) + stone_thickness();

module upper_fireplace() {

    difference() {
        union() {
            color("gray") {
                difference() {
                    union() {
                        translate([0, inches(1), 0]) {
                            rotate([90, 0, 0]) {
                                linear_extrude(buildout_depth()+inches(1)) {
                                    polygon([[0, 0],
                                            [0, upper_ceiling_high_point()-upper_fireplace_x_offset()*ceiling_slope()],
                                            [upper_fireplace_width(), upper_ceiling_high_point()-(upper_fireplace_x_offset()+upper_fireplace_width())*ceiling_slope()],
                                            [upper_fireplace_width(),0]]);
                                }
                            }
                        }
                        translate([upper_fireplace_width()-upper_fireplace_return_buildout()-inches(1), -buildout_depth(), 0]) {
                            rotate([90, 0, 0]) {
                                rotate([0, 90, 0]) {
                                    linear_extrude(upper_fireplace_return_buildout()+inches(1)) {
                                        polygon([[0, 0],
                                                [0, master_wall_height()+(upper_fireplace_return_width())*ceiling_slope()],
                                                [upper_fireplace_return_width()+inches(1), master_wall_height()-inches(1)*ceiling_slope()],
                                                [upper_fireplace_return_width()+inches(1),0]]);
                                    }
                                }
                            }
                        }
                        translate([upper_fireplace_width()-upper_fireplace_return_buildout()-exterior_wall_thickness(), -buildout_depth(), 0]) {
                            rotate([90, 0, 0]) {
                                rotate([0, 90, 0]) {
                                    linear_extrude(exterior_wall_thickness()+upper_fireplace_return_buildout()) {
                                        polygon([[0, 0],
                                                [0, master_wall_height()+(upper_fireplace_return_width())*ceiling_slope()],
                                                [buildout_depth()+inches(1), master_wall_height()+(fireplace_return_to_master_interior_length()-inches(1))*ceiling_slope()],
                                                [buildout_depth()+inches(1),0]]);
                                    }
                                }
                            }
                        }
                    }

                    translate([-inches(1),-buildout_depth()-inches(1),top_recess_y_offset()]) {
                        cube([top_recess_width()+inches(1),recess_depth()+stone_thickness()+inches(1),top_recess_height()]);
                        cube([recess_depth()+stone_thickness()+inches(1),buildout_depth()+inches(3),top_recess_height()]);
                    }
if (false) {
                    translate([upper_fireplace_width()-upper_fireplace_return_buildout(),upper_fireplace_return_width()-upper_fireplace_return_recess_width()-buildout_depth(),top_recess_y_offset()]) {
                        cube([recess_depth()+stone_thickness()+inches(1),upper_fireplace_return_recess_width()+inches(1),top_recess_height()]);
                    }
}
                    translate([upper_fireplace_width()-middle_recess_width(),-buildout_depth()-inches(1),middle_recess_y_offset()]) {
                        cube([middle_recess_width()+inches(1),recess_depth()+stone_thickness()+inches(1),middle_recess_height()]);
                        translate([middle_recess_width()-upper_fireplace_return_buildout(),0,0]) {
                            cube([upper_fireplace_return_buildout()+inches(1),upper_fireplace_return_recess_width(),middle_recess_height()]);
                        }
                    }
if (false) {
                    translate([upper_fireplace_width()-upper_fireplace_return_buildout(),upper_fireplace_return_width()-upper_fireplace_return_recess_width()-buildout_depth(),bottom_recess_y_offset()]) {
                        cube([recess_depth()+stone_thickness()+inches(1),upper_fireplace_return_recess_width()+inches(1),bottom_recess_height()]);
                    }
}
                    translate([-inches(1),-buildout_depth()-inches(1),bottom_recess_y_offset()]) {
                        cube([bottom_recess_width()+inches(1),recess_depth()+stone_thickness()+inches(1),bottom_recess_height()]);
                        cube([recess_depth()+stone_thickness()+inches(1),buildout_depth()+inches(3),bottom_recess_height()]);
                    }

                    translate([upper_fireplace_width()-bottomest_recess_width(),-buildout_depth()-inches(1),bottomest_recess_y_offset()]) {
                        translate([recess_overlap()+radiant_panel_width()/2+radiant_panel_margin(),0,0]) {
                            cube([bottomest_recess_width()-recess_overlap()-radiant_panel_width()/2-radiant_panel_margin()+inches(1),recess_depth()+stone_thickness()+inches(1),bottomest_recess_height()]);
                        }
                        translate([bottomest_recess_width()-upper_fireplace_return_buildout(),0,0]) {
                            cube([upper_fireplace_return_buildout()+inches(1),upper_fireplace_return_recess_width(),bottomest_recess_height()]);
                        }
                    }
                }
            }

            color("darkgray") {
                translate([recess_depth(),-buildout_depth()+recess_depth(),top_recess_y_offset()]) {
                    cube([top_recess_width()-recess_depth(),stone_thickness(),top_recess_height()]);
                    cube([stone_thickness(),buildout_depth()-recess_depth(),top_recess_height()]);
                }
                translate([upper_fireplace_width()-upper_fireplace_return_buildout(),buildout_depth()-recess_depth()-stone_thickness(),top_recess_y_offset()]) {
                    cube([stone_thickness(),fireplace_return_to_master_interior_length()+recess_depth()+stone_thickness()-buildout_depth(),top_recess_height()]);
                }
                translate([upper_fireplace_width()-middle_recess_width(),-buildout_depth()+recess_depth(),middle_recess_y_offset()]) {
                    cube([middle_recess_width()-recess_depth(),stone_thickness(),middle_recess_height()]);
                    translate([middle_recess_width()-upper_fireplace_return_buildout(),0,0]) {
                        cube([stone_thickness(),upper_fireplace_return_recess_width()-recess_depth(),middle_recess_height()]);
                    }
                }
                translate([upper_fireplace_width()-upper_fireplace_return_buildout(),buildout_depth()-recess_depth()-stone_thickness(),bottom_recess_y_offset()]) {
                    cube([stone_thickness(),fireplace_return_to_master_interior_length()+recess_depth()+stone_thickness()-buildout_depth(),bottom_recess_height()]);
                }
                translate([recess_depth(),-buildout_depth()+recess_depth(),bottom_recess_y_offset()]) {
                    cube([bottom_recess_width()-recess_depth(),stone_thickness(),bottom_recess_height()]);
                    cube([stone_thickness(),buildout_depth()-recess_depth(),bottom_recess_height()]);
                }
                translate([upper_fireplace_width()-bottomest_recess_width(),-buildout_depth()+recess_depth(),bottomest_recess_y_offset()]) {
                    translate([recess_overlap()+radiant_panel_width()/2+radiant_panel_margin(),0,0]) {
                        cube([bottomest_recess_width()-recess_depth()-recess_overlap()-radiant_panel_width()/2-radiant_panel_margin(),stone_thickness(),bottomest_recess_height()]);
                    }
                    translate([bottomest_recess_width()-upper_fireplace_return_buildout(),0,0]) {
                        cube([stone_thickness(),upper_fireplace_return_recess_width()-recess_depth(),bottomest_recess_height()]);
                    }
                }
            }
        }

        // for radiant panel
        translate([upper_fireplace_width()/2-radiant_panel_width()/2-radiant_panel_margin(),-buildout_depth()-inches(1),0]) {
            color("blue") {
                union() {
                    cube([radiant_panel_width()+2*radiant_panel_margin(),radiant_panel_recess()+inches(1),bench_top_height()+radiant_panel_height()+radiant_panel_margin()]);
                    translate([radiant_panel_width()+2*radiant_panel_margin()-inches(1),0,bench_top_height()+(radiant_panel_height()+radiant_panel_margin())/2-recess_band_height()/2]) {
                        cube([inches(1.01),radiant_panel_recess()+inches(1),recess_band_height()]);
                    }
                }
            }
        }
    }


    translate([0,-buildout_depth(),0]) {

        // tv
        translate([(upper_fireplace_width()/2)-(upper_tv_width()/2),-inches(2),upper_tv_vertical_center()-(upper_tv_height()/2)]) {
            color("black") cube([upper_tv_width(),inches(1),upper_tv_height()]);
        }
        // radiant heater
        translate([upper_fireplace_width()/2-radiant_panel_width()/2,-radiant_panel_thickness()-radiant_panel_standoff()+radiant_panel_recess(),bench_top_height()])
                color("black") cube([radiant_panel_width(),radiant_panel_thickness(),radiant_panel_height()]);
        *translate([upper_fireplace_width()/2-radiant_panel_width()/2,-radiant_panel_thickness()+radiant_panel_recess()-feet(1),bench_top_height()+radiant_panel_height()])
                color("red") cube([radiant_panel_width(),radiant_panel_thickness()+feet(1),feet(1)]);

        cartridge_width = cartridge_width();
        cartridge_depth = inches(12);
        cartridge_height = inches(10);
        cartridge_recess = inches(2);
        cartridge_z_offset = bench_top_height()-cartridge_recess-cartridge_height;
        cartridge_margin = inches(.75);

        mantel_width=bench_opening_width()+2*inches(4);
        mantel_depth=inches(13);
        mantel_thickness=inches(5);

        // mantel

echo(mantel_height=bench_top_height()+radiant_panel_height()+radiant_panel_margin());

//        translate([(upper_fireplace_width()/2)-(mantel_width/2),-mantel_depth+stone_thickness()/*+recess_depth()+inches(1)*/,(bench_top_height()+radiant_panel_height()+radiant_panel_margin()+upper_tv_vertical_center()-upper_tv_height()/2)/2-mantel_thickness/2])
        translate([(upper_fireplace_width()/2)-(mantel_width/2),-mantel_depth+stone_thickness()/*+recess_depth()+inches(1)*/,(bench_top_height()+radiant_panel_height()+radiant_panel_margin()+inches(2))])
                color(walnut()) cube([mantel_width,mantel_depth,mantel_thickness]);

if (false) {
        translate([(upper_fireplace_width()/2),-mantel_depth+stone_thickness()/*+recess_depth()+inches(1)*/,(upper_tv_vertical_center()+(bench_top_height()+upper_tv_height()/2))/2-mantel_thickness/2])
                color(walnut()) cube([upper_fireplace_width()/2+inches(3),mantel_depth,mantel_thickness]);
        translate([upper_fireplace_width(),-mantel_depth+stone_thickness()/*+recess_depth()+inches(1)*/,(upper_tv_vertical_center()+(bench_top_height()+upper_tv_height()/2))/2-mantel_thickness/2])
                color(walnut()) cube([inches(3),feet(4.25),mantel_thickness]);
}

        // cartridges
        color( "black") {
            union() {
                translate([upper_fireplace_width()/2-cartridge_width/2, -cartridge_depth-cartridge_margin+buildout_depth()-radiant_panel_thickness(), cartridge_z_offset]) {
                    cube([cartridge_width, cartridge_depth, cartridge_height]);
                    translate([0, cartridge_depth/2-inches(1), cartridge_height-inches(1)]) {
                        cube([cartridge_width, inches(2), inches(2)]);
                    }
                }
            }
        }

        // bench top
        bench_reveal = inches(3);
        bench_opening_width=bench_opening_width();
        color([0.55,0.55,0.55]/*"darkgray"*/) {
            difference() {
                translate([bench_reveal, -bench_depth(), bench_top_height()-bench_top_thickness()]) {
                    echo("bench width", upper_fireplace_width()-2*bench_reveal);
                    echo("bench side width", upper_fireplace_width() - 2*bench_reveal - bench_opening_width/2);
                    cube([upper_fireplace_width()-2*bench_reveal, bench_depth()+inches(1), bench_top_thickness()]);
                }
                translate([upper_fireplace_width()/2-bench_opening_width/2, -cartridge_depth-2*cartridge_margin+buildout_depth()-radiant_panel_thickness(), bench_top_height()-bench_top_thickness()-inches(1)]) {
                    cube([bench_opening_width,cartridge_depth+2*cartridge_margin + inches(2), bench_top_thickness()+inches(2)]);
                }
            }
        }

        // bench skirt
        bench_top_overhang = inches(0.5);
        color("gray") {
            difference() {
                union() {
                    translate([bench_reveal+bench_top_overhang, -bench_depth()+bench_top_overhang, 0]) {
                        cube([upper_fireplace_width()-2*(bench_reveal+bench_top_overhang), stone_thickness(), bench_top_height()-bench_top_thickness()+inches(1)]);
                    }
                    translate([bench_reveal+bench_top_overhang, -bench_depth()+bench_top_overhang, 0]) {
                        cube([stone_thickness(), bench_depth()-bench_top_overhang+inches(1), bench_top_height()-bench_top_thickness()+inches(1)]);
                    }
                    translate([upper_fireplace_width()-bench_reveal-bench_top_overhang-stone_thickness(), -bench_depth()+bench_top_overhang, 0]) {
                        cube([stone_thickness(), bench_depth()-bench_top_overhang+inches(1), bench_top_height()-bench_top_thickness()+inches(1)]);
                    }
                }
                translate([bench_reveal+bench_top_overhang+stone_thickness()+framing_thickness()+inches(0.5),-bench_depth(),0]) {
                    cube([subwoofer_width()+inches(1),subwoofer_bottom_depth()+inches(2),subwoofer_height()+inches(1)]);
                }
                translate([upper_fireplace_width()-bench_reveal-bench_top_overhang-stone_thickness()-framing_thickness()-inches(0.5)-subwoofer_width()-inches(1),-bench_depth(),0]) {
                    cube([subwoofer_width()+inches(1),subwoofer_bottom_depth()+inches(2),subwoofer_height()+inches(1)]);
                }
            }
        }

        translate([bench_reveal+bench_top_overhang+stone_thickness()+framing_thickness()+inches(1),-bench_depth()+inches(4),0]) {
            subwoofer();
        }
        translate([upper_fireplace_width()-bench_reveal-bench_top_overhang-stone_thickness()-framing_thickness()-subwoofer_width()-inches(1),-bench_depth()+inches(4),0]) {
            subwoofer();
        }

        // bench frame
        *color("tan") {
            difference() {
                union() {
                    bench_frame_height = bench_top_height()-bench_top_thickness();
                    translate([stone_thickness(),-framing_thickness(),0]) {
                        cube([upper_fireplace_width()-2*stone_thickness(),framing_thickness(),bench_frame_height]);
                    }
                    translate([stone_thickness(),-bench_depth()+stone_thickness(),0])
                            cube([framing_thickness(),bench_depth()-framing_thickness()-stone_thickness(),inches(14.5)]);
                }
                translate([bench_reveal+bench_top_overhang+stone_thickness()+framing_thickness(),-bench_depth(),0]) {
                    cube([subwoofer_width()+stone_thickness()+inches(1),subwoofer_bottom_depth()+inches(2),subwoofer_height()+inches(1)]);
                }
            }
        }
    }
}

module lower_fireplace() {

    bench_offset = (lower_fireplace_width()-lower_fireplace_unit_width()-2*subwoofer_bench_width())/4;

    color("gray") {
        difference() {
            union() {
                translate([0, -buildout_depth(), 0]) {
                    cube([lower_fireplace_width(),buildout_depth()+inches(1),lower_ceiling_height()]);
                }
                translate([lower_fireplace_width()-lower_fireplace_return_buildout()-inches(1), -buildout_depth(), 0]) {
                    cube([lower_fireplace_return_buildout()+inches(1),lower_fireplace_return_width()+inches(1),lower_ceiling_height()]);
                }
            }
            translate([lower_fireplace_width(), 0, 0]) {
                rotate([0,0,90]) {
                    lower_fireplace_return_window_cutout(thickness=lower_fireplace_return_buildout()+inches(1));
                }
            }
            translate([bench_offset,-subwoofer_bench_depth(),0]) {
                cube([subwoofer_bench_width(),subwoofer_bench_depth(),subwoofer_bench_height()]);
            }
            translate([lower_fireplace_width()-bench_offset-subwoofer_bench_width(),-subwoofer_bench_depth(),0]) {
                cube([subwoofer_bench_width(),subwoofer_bench_depth(),subwoofer_bench_height()]);
            }
        }
    }

    translate([0,-buildout_depth(),0]) {

        // tv
        translate([(lower_fireplace_width()/2)-(lower_tv_width()/2),-inches(2),lower_tv_vertical_center()-(lower_tv_height()/2)]) {
            color("black") cube([lower_tv_width(),inches(1),lower_tv_height()]);
        }

        // fireplace
        translate([lower_fireplace_width()/2-lower_fireplace_unit_width()/2,-lower_fireplace_unit_thickness(),lower_fireplace_unit_bottom()]) {
            color("black") cube([lower_fireplace_unit_width(),lower_fireplace_unit_thickness(),lower_fireplace_unit_height()]);
            translate([lower_fireplace_unit_width()/2-lower_fireplace_unit_fire_width()/2,-inches(0.1),lower_fireplace_unit_height()/2-lower_fireplace_unit_fire_height()/2]) {
                color("red",0.2) cube([lower_fireplace_unit_fire_width(),lower_fireplace_unit_thickness(),lower_fireplace_unit_fire_height()]);
            }
        }
    }

    #translate([bench_offset,0,0]) {
        subwoofer_bench();
    }
    translate([lower_fireplace_width()-bench_offset-subwoofer_bench_width(),0,0]) {
        subwoofer_bench();
    }
    #translate([bench_offset+subwoofer_bench_width(),-subwoofer_bench_depth()+inches(0),0]) {
        color(walnut()) cube([lower_fireplace_unit_width()+2*bench_offset,subwoofer_bench_depth()-inches(0),inches(10)]);
    }
}

function subwoofer_bench_thickness() = inches(2);
function subwoofer_bench_width() = subwoofer_width()+2*subwoofer_bench_thickness()+2*inches(0);
function subwoofer_bench_height() = subwoofer_height()+subwoofer_bench_thickness();
function subwoofer_bench_depth() = inches(16)+buildout_depth();

module subwoofer_bench() {
    bench_thickness=subwoofer_bench_thickness();
    bench_width=subwoofer_bench_width();
    bench_height=subwoofer_bench_height();
    bench_depth=subwoofer_bench_depth();
    translate([0,-bench_depth,0]) {
        color(walnut()) {
            translate([bench_width/2-subwoofer_width()/2-bench_thickness,0,0]) {
                cube([bench_thickness,bench_depth,bench_height]);
            }
            translate([bench_width/2+subwoofer_width()/2,0,0]) {
                cube([bench_thickness,bench_depth,bench_height]);
            }
            translate([0,0,bench_height-bench_thickness]) {
                cube([bench_width,bench_depth,bench_thickness]);
            }
        }
        translate([bench_width/2-subwoofer_width()/2,inches(1.5),0]) {
            subwoofer();
        }
    }
}

function bench_top_height() = bench_top_thickness() + subwoofer_height() + inches(1);
function bench_depth() = inches(24);
function stone_thickness() = inches(2.5);
function bench_top_thickness() = inches(3);
function framing_thickness() = inches(1.5);

// Standalone rendering
union() {
    walls();
    floor();
    lower_floor();
    translate([0,-feet(30),upper_subfloor_height()+inches(98)]) {
        color([0.25, 0.25, 0.25]) {
            cube([feet(4),feet(30),inches(6)]);
        }
    }
}
translate([upper_fireplace_x_offset(),0,upper_subfloor_height()]) {
    upper_fireplace();
}
translate([lower_fireplace_x_offset(),0,lower_subfloor_height()]) {
    lower_fireplace();
}
//walls();
