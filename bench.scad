// brace_angle = 15
// brace_length = 12.6264 [12 5/8] (4)
//
// For 16" bench:
// leg_height = 13.375 [13 3/8] (4)
// leg_height = 9.875 [9 7/8] (2)
// leg_height = 5.375 [5 3/8] (2)
// leg_height = 4.5 [4 1/2] (2)
// leg_height = 1.875 [1 7/8] (4)
//
// For 15" bench:
// leg_height = 12.375 [12 3/8] (4)
// leg_height = 8.875 [8 7/8] (2)
// leg_height = 4.875 [4 7/8] (2)
// leg_height = 4 [4] (2)
// leg_height = 1.375 [1 3/8] (4)
//
// For 14" bench:
// leg_height = 11.375 [11 3/8] (4)
// leg_height = 7.875 [7 7/8] (2)
// leg_height = 4.375 [4 3/8] (2)
// leg_height = 3.5 [3 1/2] (2)
// leg_height = 0.875 [0 7/8] (4)
//
// plank_length = 30, width = 4.125 [4 1/8] (2)
// plank_length = 60, width = 4.125 [4 1/8] (2)
// plank_length = 30, width = 5.3125 [5 5/16] (2)
// plank_length = 60, width = 5.3125 [5 5/16] (2)
//
// support_end_bevel_angle = 30
// support_length = 57.2679 [57 1/4], bevel_both_ends = true (2)
// support_length = 32.634 [32 5/8], bevel_both_ends = false (2)
//
// top_joist_end_bevel_angle = 15
// top_joist_length_bevel_angle = 30
// top_joist_length = 19, bevel_length = true (3)
// top_joist_length = 19 (6)

function mm(x) = cm(x)/10;
function cm(x) = in(x)/2.54;
function in(x) = x;
function ft(x,i=0) = in(x*12+i);

epsilon = mm(1);
explode_gap = in(1/16);

lumber_thickness = in(1.5);
lumber_width = in(3.5);
bench_depth = in(20);
bench_length = in(60);
step_depth = bench_depth;
step_length = in(30);
step_height = in(8);
step_overlap = bench_length + step_length - ft(7);
echo(step_overlap=step_overlap);
bench_height = 2*step_height;
decking_overhang = in(1/2);
top_joist_length = bench_depth - 2*decking_overhang;

decking_natural_width = in(5+5/16);
decking_gap = in(3/8);
decking_planks = ceil((bench_depth + decking_gap) / (decking_natural_width + decking_gap));
decking_width = (bench_depth + decking_gap) / decking_planks - decking_gap;
decking_spacing = decking_width + decking_gap;
decking_thickness = in(1+1/8);

lightwalnut = [0.397, 0.315, 0.228];

side_bevel_angle = 15;
end_bevel_angle = 30;
brace_angle=side_bevel_angle;

echo(side_bevel_angle=side_bevel_angle);
echo(end_bevel_angle=end_bevel_angle);
echo(brace_angle=brace_angle);

echo(leg_setback=step_overlap-tan(end_bevel_angle)*(lumber_width+lumber_thickness));


supports_outside = false;

module top_joist(near_bottom_offset = 0, far_bottom_offset = 0) {
    if (near_bottom_offset!=0||far_bottom_offset!=0) {
        echo(top_joist_length=top_joist_length,bevel_length=true);
    } else {
        echo(top_joist_length=top_joist_length);
    }
    polyhedron(
            points=[[0, 0, lumber_thickness],
                    [top_joist_length, 0, lumber_thickness],
                    [top_joist_length - tan(side_bevel_angle)*lumber_thickness, near_bottom_offset, 0],
                    [tan(side_bevel_angle)*lumber_thickness, near_bottom_offset, 0],
                    [0, lumber_width, lumber_thickness],
                    [top_joist_length, lumber_width, lumber_thickness],
                    [top_joist_length - tan(side_bevel_angle)*lumber_thickness, lumber_width - far_bottom_offset, 0],
                    [tan(side_bevel_angle)*lumber_thickness, lumber_width - far_bottom_offset, 0]],
            faces=[[0, 1, 2, 3],
                   [4, 5, 6, 7],
                   [4, 5, 1, 0],
                   [2, 3, 7, 6],
                   [4, 0, 3, 7],
                   [1, 5, 6, 2]]);
}

module top_joists(length, bevel_far_end = true) {
    translate([decking_overhang, 0, 0]) {
        spans = floor(length / in(12));
        for (i = [0:spans]) {
            spacing = (length - lumber_width - 2*decking_overhang) / spans;
            echo(spacing=spacing);
            translate([0, decking_overhang + i * spacing, 0]) {
                if (i == 0) {
                    top_joist(near_bottom_offset = tan(end_bevel_angle)*lumber_thickness);
                } else if (i == spans && bevel_far_end) {
                    top_joist(far_bottom_offset = tan(end_bevel_angle)*lumber_thickness);
                } else {
                    top_joist();
                }
            }
        }
    }
}
module bench_top_joists() {
    top_joists(bench_length);
}

module step_top_joists() {
    top_joists(step_length, bevel_far_end = false);
}

module planks(length) {
    edge_decking_width = (bench_depth - (decking_spacing - decking_width) - (decking_planks-2) * decking_spacing) / 2;
    translate([-max(0, explode_gap-(decking_spacing - decking_width))*(decking_planks-1)/2, 0, 0]) {
        echo(plank_length=length,width=edge_decking_width);
        cube([edge_decking_width, length, decking_thickness]);
        translate([edge_decking_width + max(decking_spacing - decking_width, explode_gap), 0, 0]) {
            for (i = [0:decking_planks-3]) {
                translate([i * max(decking_spacing, decking_width+explode_gap), 0, 0]) {
                    echo(plank_length=length,width=decking_width);
                    cube([decking_width, length, decking_thickness]);
                }
            }
            translate([(decking_planks - 2) * max(decking_spacing, decking_width + explode_gap), 0, 0]) {
                echo(plank_length=length,width=edge_decking_width);
                cube([edge_decking_width, length, decking_thickness]);
            }
        }
    }
}

module support(length, bevel_far_end = true) {
    translate([0, tan(end_bevel_angle)*lumber_thickness + decking_overhang, 0]) {
        rotate([90, 0, 90]) {
            top_length = length - decking_overhang - tan(end_bevel_angle)*lumber_thickness - (bevel_far_end ? decking_overhang + tan(end_bevel_angle)*lumber_thickness : 0);
            bottom_length = length - decking_overhang - tan(end_bevel_angle)*(lumber_thickness + lumber_width) - (bevel_far_end ? decking_overhang + tan(end_bevel_angle)*(lumber_thickness + lumber_width): 0);
            echo(support_length=top_length,bevel_both_ends=bevel_far_end);
            linear_extrude(height = lumber_thickness) {
                polygon([[0, lumber_width],
                         [top_length, lumber_width],
                         [tan(end_bevel_angle)*lumber_width + bottom_length, 0],
                         [tan(end_bevel_angle)*lumber_width, 0]]);
            }
        }
    }
}

module supports(length, bevel_far_end = true) {
    inset = decking_overhang + tan(side_bevel_angle)*lumber_thickness + (supports_outside?0:lumber_thickness-explode_gap);
    translate([inset, 0, 0]) {
        support(length, bevel_far_end=bevel_far_end);
    }
    translate([bench_depth - inset - lumber_thickness, 0, 0]) {
        support(length, bevel_far_end=bevel_far_end);
    }
}

module leg(height) {
    echo(leg_height=height);
    cube([lumber_thickness, lumber_width, height]);
}

module legs(height, length, include_far_legs = true) {
    inset = decking_overhang + tan(side_bevel_angle)*lumber_thickness + (supports_outside?0:-explode_gap);
    translate([inset, step_overlap + decking_overhang, 0]) {
        translate([supports_outside?0:2*lumber_thickness-explode_gap,0,0]) mirror([supports_outside?0:1,0,0]) {
            translate([-explode_gap, 0, -explode_gap]) {
                leg(height-lumber_thickness-lumber_width);
            }
            translate([lumber_thickness, 0, -explode_gap]) {
                leg(height-lumber_thickness);
            }
        }
        translate([bench_depth-2*inset-lumber_thickness, 0, 0]) {
            translate([explode_gap,0,0]) mirror([supports_outside?0:1,0,0]) {
                translate([explode_gap, 0, -explode_gap]) {
                    leg(height-lumber_thickness-lumber_width);
                }
                translate([-lumber_thickness, 0, -explode_gap]) {
                    leg(height-lumber_thickness);
                }
            }
        }
    }
    if (include_far_legs) {
        translate([inset, length - step_overlap - lumber_width - decking_overhang, 0]) {
            translate([supports_outside?0:2*lumber_thickness-explode_gap,0,0]) mirror([supports_outside?0:1,0,0]) {
                translate([-explode_gap, 0, -3*explode_gap]) {
                    leg(step_height-decking_thickness-lumber_thickness-lumber_width);
                }
                translate([-explode_gap, 0, step_height-decking_thickness-lumber_thickness - explode_gap]) {
                    leg(height-(step_height-decking_thickness)-lumber_width);
                }
                translate([lumber_thickness, 0, -3*explode_gap]) {
                    leg(height-lumber_thickness);
                }
            }
            translate([bench_depth-2*inset-lumber_thickness, 0, 0]) {
                translate([explode_gap,0,0]) mirror([supports_outside?0:1,0,0]) {
                    translate([explode_gap, 0, -3*explode_gap]) {
                        leg(step_height-decking_thickness-lumber_thickness-lumber_width);
                    }
                    translate([explode_gap, 0, step_height-decking_thickness-lumber_thickness - explode_gap]) {
                        leg(height-(step_height-decking_thickness)-lumber_width);
                    }
                    translate([-lumber_thickness, 0, -3*explode_gap]) {
                        leg(height-lumber_thickness);
                    }
                }
            }
        }
    }
}

module brace_segment(span) {
    rotate([90, 0, 0]) {
        linear_extrude(height = lumber_thickness) {
            cut_length=lumber_width/cos(brace_angle);
            rise=tan(brace_angle)*span;
            echo(brace_length=span/cos(brace_angle));
            polygon([[0, 0],
                     [0, cut_length],
                     [span, rise + cut_length],
                     [span, rise]]);
        }
    }
}

module brace(span) {
    translate([0,0,0]) {
        brace_segment(span);
    }
    translate([span,lumber_thickness+explode_gap,0]) {
        mirror([1,0,0]) brace_segment(span);
    }
}

module bracing() {
    brace_offset=decking_overhang+tan(side_bevel_angle)*lumber_thickness+2*lumber_thickness;
    brace_span=bench_depth-2*brace_offset;
    brace_height=brace_span*tan(brace_angle)+lumber_width/cos(brace_angle);
    translate([0, -explode_gap/2, bench_height - decking_thickness - lumber_thickness - brace_height]) {
        translate([brace_offset, step_overlap + decking_overhang + lumber_thickness + (lumber_width - 2*lumber_thickness)/2, 0]) {
            brace(brace_span);
        }
    }
    translate([0, -explode_gap/2, step_height - in(1/2) - brace_height]) {
        translate([brace_offset,bench_length - (step_overlap + decking_overhang + lumber_thickness) - (lumber_width - 2*lumber_thickness)/2,0]) {
            brace(brace_span);
        }
    }
}

module bench() {
    translate([0, 0, bench_height - decking_thickness - lumber_thickness - lumber_width]) {
        supports(bench_length);
    }
    translate([0, 0, bench_height - decking_thickness - lumber_thickness + explode_gap]) {
        bench_top_joists();
    }
    translate([0, 0, bench_height - decking_thickness + 2 * explode_gap]) {
        planks(bench_length);
    }
    legs(bench_height - decking_thickness, bench_length);
    bracing();
}

module step() {
    translate([0, 0, step_height - decking_thickness - lumber_thickness - lumber_width]) {
        supports(step_length + decking_overhang + lumber_width, bevel_far_end = false);
    }
    translate([0, 0, step_height - decking_thickness - lumber_thickness + explode_gap]) {
        step_top_joists();
    }
    translate([0, 0, step_height - decking_thickness + 2 * explode_gap]) {
        planks(step_length);
    }
    legs(step_height - decking_thickness, step_length, include_far_legs = false);
}

module bench_and_step() {
    step();
    translate([0, bench_length + step_length - step_overlap + explode_gap, 2*explode_gap]) {
        mirror([0, 1, 0]) bench();
    }
}

color(lightwalnut) bench_and_step();
