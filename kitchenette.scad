function mm(x) = x/10;
function cm(x) = x;
function in(x) = x*2.54;
function ft(x,i=0) = in(x*12+i);

epsilon = mm(1);
explode_gap = mm(0);

pantry_width = in(12);
fridge_width = in(36);
fridge_cabinet_width = fridge_width + in(4);
fridge_height = in(72);
fridge_depth = in(28);
dishwasher_width = in(24);
dishwasher_depth = in(24);
dishwasher_wall_thickness = in(2);
cabinet_face_thickness = in(3/4);
lower_cabinet_face_height = in(31);
cabinet_kick_height = in(3.5);
lower_cabinet_depth = in(26);
lower_cabinet_height = in(24);
upper_cabinet_depth = in(13.25);
ceiling_height = in(107.5);
soffit_height = in(18.5);
soffit_width = in(145);  // actually 145.5, but allowing the pantry to overlap .5 in.
total_width = soffit_width + in(12);
soffit_depth = in(15.5);
wall_thickness = in(6);
wall_reveal = in(12);
sink_width = in(27);
sink_cabinet_width = in(27);
sink_depth = in(18);
sink_height = in(12);
speedoven_width = in(22+5/16);
speedoven_depth = in(17+3/4);
speedoven_height = in(14);
countertop_depth = lower_cabinet_depth + in(1/2);
countertop_thickness = cm(3);
upper_cabinet_face_height = ceiling_height - soffit_height - (cabinet_kick_height + lower_cabinet_face_height + cm(3) + in(23.5));
echo(upper_cabinet_face_height=upper_cabinet_face_height/in(1));
upper_fridge_cabinet_face_height = ceiling_height - soffit_height - fridge_height;
echo(upper_fridge_cabinet_face_height=upper_fridge_cabinet_face_height/in(1));

speedoven_xoffset = total_width - fridge_cabinet_width - dishwasher_wall_thickness - dishwasher_width - pantry_width - in(2) - speedoven_width;

lightwalnut = [0.397, 0.315, 0.228];
darkwalnut = [0.397*0.85, 0.315*0.85, 0.228*0.85];

module soffit() {
    translate([pantry_width, -soffit_depth, ceiling_height - soffit_height]) {
        color("lightgray") cube([soffit_width, soffit_depth, soffit_height]);
    }
}

module walls() {
    translate([-wall_reveal, -lower_cabinet_depth - wall_reveal, ceiling_height]) {
        color("lightgray") cube([wall_reveal + total_width + wall_thickness, ft(5), wall_thickness]);
    }
    translate([-wall_reveal, -lower_cabinet_depth - wall_reveal, -wall_thickness]) {
        color("lightgray") cube([wall_reveal + total_width + wall_thickness, ft(5), wall_thickness]);
    }
    translate([-wall_reveal, 0, 0]) {
        color("lightgray") cube([wall_reveal + total_width + wall_thickness, wall_thickness, ceiling_height]);
    }
    translate([total_width, -(lower_cabinet_depth + wall_reveal), 0]) {
        color("lightgray") cube([wall_thickness, lower_cabinet_depth + wall_reveal, ceiling_height]);
    }
}

module fridge() {
    translate([pantry_width + in(2), -fridge_depth - in(2), 0]) {
        color("gray") cube([fridge_width, fridge_depth, fridge_height - 1]);
    }
}

module dishwasher() {
    translate([pantry_width + fridge_cabinet_width + dishwasher_wall_thickness, -dishwasher_depth, 0]) {
        color("gray") cube([dishwasher_width, dishwasher_depth, cabinet_kick_height + lower_cabinet_face_height]);
    }
}

module sink() {
    difference() {
        children();
        translate([in(2) + (sink_cabinet_width - sink_width)/2, -in(1), lower_cabinet_face_height - sink_height]) {
            color(lightwalnut) cube([sink_width, sink_depth, sink_height + epsilon]);
        }
    }
    translate([in(2) + (sink_cabinet_width - sink_width)/2, -in(1), lower_cabinet_face_height - sink_height]) {
        color("gray") cube([sink_width, sink_depth, sink_height]);
    }
}

module speedoven() {
    yoffset = lower_cabinet_face_height - speedoven_height - in(2);
    difference() {
        children();
        translate([speedoven_xoffset, -in(1/2), yoffset]) {
            color(lightwalnut) cube([speedoven_width, speedoven_depth, speedoven_height]);
        }
    }
    translate([speedoven_xoffset, -in(1/2), yoffset]) {
        color("gray") cube([speedoven_width, speedoven_depth, speedoven_height]);
    }
}

module countertop() {
    translate([pantry_width + fridge_cabinet_width, -countertop_depth, cabinet_kick_height + lower_cabinet_face_height]) {
        color("gray") {
            difference() {
                cube([total_width - pantry_width - fridge_cabinet_width, countertop_depth, countertop_thickness]);
                translate([dishwasher_wall_thickness + dishwasher_width + in(2) + in(1), -in(1), -epsilon]) {
                    cube([sink_width - 2*in(1), sink_depth - in(1), countertop_thickness + 2*epsilon]);
                }
            }
        }
    }
}

module dishwasher_wall() {
    translate([pantry_width + fridge_cabinet_width, -lower_cabinet_depth, cabinet_kick_height]) {
        color(lightwalnut) cube([dishwasher_wall_thickness, lower_cabinet_depth, lower_cabinet_face_height]);

        translate([-in(2), in(3), -cabinet_kick_height])
        color(darkwalnut) cube([in(2) + dishwasher_wall_thickness, lower_cabinet_depth - in(3), cabinet_kick_height]);
    }
}

cabinet_door_gap = in(1/8);

module cabinet_door(xoffset, yoffset, width, height) {
    echo(width=width/in(1),height=height/in(1))
    difference() {
        children();
        translate([xoffset, -epsilon, yoffset]) {
            color("black") cube([width, cabinet_face_thickness + 2*epsilon, height]);
        }
    }
    translate([xoffset + cabinet_door_gap/2, 0, yoffset + cabinet_door_gap/2]) {
        intersection() {
            color(lightwalnut) cube([width - cabinet_door_gap/2, cabinet_face_thickness, height - cabinet_door_gap / 2]);
            translate([cabinet_door_gap/2, -epsilon, cabinet_door_gap/2]) {
                color("black") cube([width - 2*cabinet_door_gap, cabinet_face_thickness, height - 2*cabinet_door_gap]);
            }
        }
    }
}

module glass_cabinet_door(xoffset, yoffset, width, height) {
    difference() {
        cabinet_door(xoffset, yoffset, width, height) {
            children();
        }
        translate([xoffset + in(2), -epsilon, yoffset + in(2)]) {
            color("black") cube([width - 2*in(2), cabinet_face_thickness/2 + epsilon, height - 2*in(2)]);
        }
    }
}

module cabinets_face(width, height) {
    color(lightwalnut) cube([width, cabinet_face_thickness, height]);
    color("black") translate([epsilon, cabinet_face_thickness + epsilon, epsilon]) cube([width - 2*epsilon, epsilon, height - 2*epsilon]);
}

module pantry() {
    translate([0, -lower_cabinet_depth, cabinet_kick_height]) {
        color(lightwalnut) cube([cabinet_face_thickness, lower_cabinet_depth, ceiling_height - cabinet_kick_height]);
        translate([pantry_width - cabinet_face_thickness, 0, 0]) {
            color(lightwalnut) cube([cabinet_face_thickness, lower_cabinet_depth, ceiling_height - cabinet_kick_height]);
        }
        cabinet_door(in(2), in(2), pantry_width - 2*in(2), ceiling_height - soffit_height - upper_cabinet_face_height - cabinet_kick_height - in(2))
        cabinet_door(in(2), ceiling_height - soffit_height - upper_cabinet_face_height - cabinet_kick_height + in(2), pantry_width - 2*in(2), upper_cabinet_face_height + soffit_height - 2*in(2))
        cabinets_face(pantry_width, ceiling_height - cabinet_kick_height);

        translate([0, in(3), -cabinet_kick_height])
        color(darkwalnut) cube([pantry_width + in(2), lower_cabinet_depth - in(3), cabinet_kick_height]);

        color(lightwalnut) cube([pantry_width, lower_cabinet_depth, cabinet_face_thickness]);
    }
}

module lower_cabinets_face() {
    translate([pantry_width + fridge_cabinet_width + dishwasher_wall_thickness + dishwasher_width, -lower_cabinet_depth, cabinet_kick_height]) {
        sink()
        speedoven()
        cabinet_door(in(2), in(2), sink_cabinet_width/2, lower_cabinet_face_height - sink_height - 2*in(2))
        cabinet_door(in(2) + sink_cabinet_width/2, in(2), sink_cabinet_width/2, lower_cabinet_face_height - sink_height - 2*in(2))
        cabinet_door(speedoven_xoffset, in(2), speedoven_width, lower_cabinet_face_height - speedoven_height - 3*in(2))
        cabinet_door(sink_cabinet_width + 2*in(2), lower_cabinet_face_height - in(2) - in(6), speedoven_xoffset - sink_cabinet_width - 3*in(2), in(6))
        cabinet_door(sink_cabinet_width + 2*in(2), in(2), (speedoven_xoffset - sink_cabinet_width - 3*in(2)) / 2, lower_cabinet_face_height - in(6) - 2*in(2))
        cabinet_door(sink_cabinet_width + 2*in(2) + (speedoven_xoffset - sink_cabinet_width - 3*in(2)) / 2, in(2), (speedoven_xoffset - sink_cabinet_width - 3*in(2)) / 2, lower_cabinet_face_height - in(6) - 2*in(2))
        cabinets_face(total_width - pantry_width - fridge_cabinet_width - dishwasher_wall_thickness - dishwasher_width, lower_cabinet_face_height);

        translate([0, in(3), -cabinet_kick_height])
        color(darkwalnut) cube([total_width - pantry_width - fridge_cabinet_width - dishwasher_wall_thickness - dishwasher_width, lower_cabinet_depth - in(3), cabinet_kick_height]);

        color(lightwalnut) cube([total_width - pantry_width - fridge_cabinet_width - dishwasher_wall_thickness - dishwasher_width, lower_cabinet_depth, cabinet_face_thickness]);
    }
}

module upper_cabinets_face() {
    //dishwasher_upper_door_width = (total_width - pantry_width - fridge_cabinet_width - dishwasher_wall_thickness - 3*in(2)) / 5;
    //sink_upper_door_width = dishwasher_upper_door_width;
    //counter_upper_door_width = sink_upper_door_width;
    //speedoven_upper_door_width = sink_upper_door_width;
    sink_upper_door_width = (total_width - pantry_width - fridge_cabinet_width - dishwasher_wall_thickness - dishwasher_width - in(2) - sink_cabinet_width/2 - 2*in(2)) / 3;
    dishwasher_upper_door_width = dishwasher_width + sink_cabinet_width/2 - sink_upper_door_width;
    counter_upper_door_width = sink_upper_door_width;
    speedoven_upper_door_width = sink_upper_door_width;
    translate([pantry_width + fridge_cabinet_width, -upper_cabinet_depth, ceiling_height - soffit_height - upper_cabinet_face_height]) {
        glass_cabinet_door(dishwasher_wall_thickness, in(2), dishwasher_upper_door_width, upper_cabinet_face_height - 2*in(2))
        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_upper_door_width + in(2), in(2), sink_upper_door_width, upper_cabinet_face_height - 2*in(2))
        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_upper_door_width + in(2) + sink_upper_door_width, in(2), sink_upper_door_width, upper_cabinet_face_height - 2*in(2))
        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_upper_door_width + in(2) + 2*sink_upper_door_width + in(2), in(2), counter_upper_door_width, upper_cabinet_face_height - 2*in(2))
        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_upper_door_width + in(2) + 2*sink_upper_door_width + in(2) + counter_upper_door_width, in(2), speedoven_upper_door_width, upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness, in(2), dishwasher_width/2, upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_width/2, in(2), dishwasher_width/2, upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_width + in(2), in(2), sink_cabinet_width/2, upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_width + in(2) + sink_cabinet_width/2, in(2), sink_cabinet_width/2, upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_width + in(2) + sink_cabinet_width + in(2), in(2), in(11.365), upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_width + in(2) + sink_cabinet_width + in(2) + in(11.365), in(2), in(11.365), upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_width + speedoven_xoffset, in(2), speedoven_width/2, upper_cabinet_face_height - 2*in(2))
//        glass_cabinet_door(dishwasher_wall_thickness + dishwasher_width + speedoven_xoffset + speedoven_width/2, in(2), speedoven_width/2, upper_cabinet_face_height - 2*in(2))
        cabinets_face(total_width - pantry_width - fridge_cabinet_width, upper_cabinet_face_height);

        color(lightwalnut) cube([total_width - pantry_width - fridge_cabinet_width, upper_cabinet_depth, cabinet_face_thickness]);
    }
}

//upper_fridge_cabinet_depth = soffit_depth;
//upper_fridge_cabinet_depth = upper_cabinet_depth;
upper_fridge_cabinet_depth = lower_cabinet_depth;

module upper_fridge_cabinets_face() {
    translate([pantry_width + in(2), -upper_fridge_cabinet_depth, ceiling_height - soffit_height - upper_fridge_cabinet_face_height]) {
        cabinet_door(0, in(2), fridge_width/2, upper_fridge_cabinet_face_height - 2*in(2))
        cabinet_door(fridge_width/2, in(2), fridge_width/2, upper_fridge_cabinet_face_height - 2*in(2))
        union() {
            translate([-in(2), 0, 0]) {
                cabinets_face(fridge_cabinet_width, upper_fridge_cabinet_face_height);
                translate([0, upper_fridge_cabinet_depth-lower_cabinet_depth, cabinet_kick_height - (ceiling_height - soffit_height - upper_fridge_cabinet_face_height)]) {
                    color(lightwalnut) cube([in(2), lower_cabinet_depth, ceiling_height - soffit_height - cabinet_kick_height]);
                    translate([fridge_width + in(2), 0, 0]) {
                        color(lightwalnut) cube([in(2), lower_cabinet_depth, ceiling_height - soffit_height - cabinet_kick_height]);
                    }
                }
            }
        }

        translate([0, 0, upper_fridge_cabinet_face_height - cabinet_face_thickness]) {
            color(lightwalnut) cube([fridge_width, upper_cabinet_depth, cabinet_face_thickness]);
        }
    }

}

echo(upper_cabinet_face_height=upper_cabinet_face_height/in(1));

rotate([0, 0, 180]) {
walls();
soffit();
pantry();
fridge();
dishwasher_wall();
dishwasher();
upper_cabinets_face();
upper_fridge_cabinets_face();
lower_cabinets_face();
countertop();
}
