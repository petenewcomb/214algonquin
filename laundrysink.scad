function mm(x) = x/10;
function cm(x) = x;
function in(x) = x*2.54;
function ft(x,i=0) = in(x*12+i);

epsilon = mm(1);
explode_gap = mm(0);

thin = cm(1);
thick = cm(3);
adhesive_thickness = in(7/16) - cm(1);

counter_width = in(50+1/2);
counter_depth = in(27+1/2);
counter_thickness = thick;
basin_cutout_depth = in(20+1/4);
basin_cutout_width = in(21+1/2);
basin_cutout_offset = in(14+1/2);

sill_width = in(50+1/2);
sill_depth = in(3+13/16);
sill_window_width = in(33+1/2);
sill_window_offset = in(8+1/2);
sill_window_depth = in(6+11/16);
sill_thickness = thin;

backsplash_height = in(8+7/8);
backsplash_width = in(50+1/2);
backsplash_thickness = thin;

sidesplash_height = in(20) - counter_thickness; //in(8+7/8);
sidesplash_depth = in(27+1/16);
sidesplash_thickness = thin;

shelf_width = in(62+3/4);
shelf_depth = in(30+1/4);
shelf_thickness = in(3/4);

partition_thickness = in(3/4);
partition_height = in(53+3/4);
partition_depth = in(30+1/4);
partition_cutout_depth = in(3+3/8);
partition_cutout_height = in(44+1/2);

machine_depth = in(34);
machine_height = in(53.5);
machine_width = in(27);


module counter() {
    difference() {
        cube([counter_width,counter_depth,counter_thickness]);
        translate([basin_cutout_offset, -epsilon, -epsilon]) {
            cube([basin_cutout_width, basin_cutout_depth + epsilon, counter_thickness + 2*epsilon]);
        }
    }
}
module sill() {
    union() {
        cube([sill_width,sill_depth,sill_thickness]);
        translate([sill_window_offset, 0, 0]) {
            cube([sill_window_width,sill_window_depth,sill_thickness]);
        }
    }
}
module backsplash() {
    cube([backsplash_width,backsplash_thickness,backsplash_height]);
}
module sidesplash() {
    cube([sidesplash_thickness,sidesplash_depth,sidesplash_height]);
}

color("gray") {
    translate([-explode_gap, cabinet_depth - counter_depth - explode_gap, cabinet_height + explode_gap]) {
        counter();
        translate([0, 0, counter_thickness + explode_gap]) {
            translate([0, counter_depth - adhesive_thickness - backsplash_thickness, 0]) {
                backsplash();
                translate([0, 0, backsplash_height + explode_gap]) {
                    sill();
                }
            }
            translate([0, -explode_gap, 0]) {
                sidesplash();
            }
            translate([counter_width - sidesplash_thickness, -explode_gap, 0]) {
                sidesplash();
            }
        }
    }
}

cabinet_width = in(50+1/2);
cabinet_depth = in(26+7/8);
cabinet_height = in(34+1/2);
cabinet_to_sill = in(10);
window_to_side = in(8+1/2);
window_width = in(33+1/2);
window_height = in(34);
sill_to_window = in(6+1/4);
sill_to_upperwall = in(3+3/8);
wall_thickness = in(6);
wall_height = ft(8);
sidewall_to_sidewall = in(113+1/4);

basin_to_back = in(7+1/2);
basin_width = in(21);
basin_to_side = in(14+3/4);
basin_depth = in(10);
basin_front_to_back = in(17.5);

sink_width = in(24);
sink_height = basin_depth + epsilon;
sink_overhang = in(1/2);
sink_depth = cabinet_depth + sink_overhang - basin_to_back + in(1+1/2);

module sink() {
    difference() {
        cube([sink_width, sink_depth, sink_height]);
        translate([(sink_width - basin_width) / 2, sink_depth - in(1+1/2) - basin_front_to_back, sink_height - basin_depth]) {
            cube([basin_width, basin_front_to_back, basin_depth + epsilon]);
        }
    }
}
module cabinet() {
    difference() {
        cube([cabinet_width, cabinet_depth, cabinet_height]);
        translate([cabinet_width - basin_to_side - basin_width - (sink_width - basin_width) / 2, -epsilon, cabinet_height - sink_height]) {
            cube([sink_width, sink_depth - sink_overhang + epsilon, sink_height + epsilon]);
        }
    }
}
module partition() {
    difference() {
        cube([partition_thickness, partition_depth, partition_height]);
        translate([-epsilon, partition_depth - partition_cutout_depth, -epsilon]) {
            cube([partition_thickness + 2*epsilon, partition_cutout_depth + epsilon, partition_cutout_height + epsilon]);
        }
    }
}
module shelf() {
    cube([shelf_width, shelf_depth, shelf_thickness]);
}
module sillwall() {
    cube([sidewall_to_sidewall, sill_to_upperwall, cabinet_height + cabinet_to_sill]);
}
module window() {
    window_thickness = wall_thickness - (sill_to_window - sill_to_upperwall);
    difference() {
        cube([window_width, window_thickness, window_height]);
        translate([in(1), -epsilon, in(1)]) {
            cube([window_width - in(2), window_thickness + 2*epsilon, window_height - in(2)]);
        }
    }
}
module window_opening() {
    cube([window_width, wall_thickness + 2*epsilon, window_height]);
}
module backwall() {
    difference() {
        cube([sidewall_to_sidewall, wall_thickness, wall_height]);
        translate([sidewall_to_sidewall - window_to_side - window_width, -epsilon, cabinet_height + cabinet_to_sill]) {
            window_opening();
        }
    }
}
module sidewall() {
    cube([wall_thickness, cabinet_depth + sill_to_upperwall + 2 * wall_thickness, wall_height]);
}
module walls() {
    union() {
        translate([-shelf_width - explode_gap, cabinet_depth, 0]) {
            sillwall();
            translate([0, sill_to_upperwall, 0]) {
                backwall();
            }
        }
        translate([cabinet_width - window_to_side - window_width - explode_gap, cabinet_depth + sill_to_window, cabinet_height + cabinet_to_sill]) {
            window();
        }
        translate([cabinet_width, -wall_thickness, 0]) {
            sidewall();
        }
        translate([-shelf_width - wall_thickness - 3 * explode_gap, -wall_thickness, 0]) {
            sidewall();
        }
    }
}

lightwalnut = [0.397, 0.315, 0.228];

color("lightgray") {
    walls();
}
translate([-explode_gap, -explode_gap, 0]) {
    color(lightwalnut) {
        cabinet();
        translate([-explode_gap - partition_thickness, cabinet_depth + sill_to_upperwall - partition_depth - explode_gap, explode_gap]) {
            partition();
        }
        translate([-explode_gap - shelf_width, cabinet_depth + sill_to_upperwall - shelf_depth - explode_gap, partition_height + 2*explode_gap]) {
            shelf();
        }
    }
    color("silver") {
        translate([cabinet_width - basin_to_side - basin_width - (sink_width - basin_width) / 2, -sink_overhang, cabinet_height - sink_height]) {
            sink();
        }
    }
}

