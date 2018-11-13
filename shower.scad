use <math.scad>;

tile_alpha = 0.5;
simplify_accent_tile=false;
shower_bar_alpha = 1.0;
stud_alpha = 1.0;
drywall_alpha = 0.4;
ceiling_alpha = 0.8;
floor_tile_alpha = 0.8;
accent_tile_alpha = 0.3;
accent_cubby = false;

$fn = 20;

function feet( x) = inches( x) * 12;
function inches( x) = x;
function mm( x) = inches( x / 25.4);

function tile_size() = [mm(300.0),mm(600.0)];
function tile_height() = tile_landscape() ? min(tile_size()[0],tile_size()[1]) : max(tile_size()[0],tile_size()[1]);
function tile_width() = tile_landscape() ? max(tile_size()[0],tile_size()[1]) : min(tile_size()[0],tile_size()[1]);
function tile_thickness() = mm(9.0);
function grout_width() = inches(1.0/8);
function drywall_thickness() = inches(1.0/2);
function wall_prep_thickness() = drywall_thickness() + inches(3.0/8); // drywall + kerdi + thinset
function floor_prep_thickness() = inches(3.0/8);
function floor_tile_thickness() = inches(1.0/4);
function floor_tile_width() = inches(24+(1.0/8));
function floor_tile_height() = inches(12-(1.0/16));

function width_in_tiles(width,tile_width=tile_width(),grout_width=grout_width()) = ceil((width + grout_width)/(tile_width+grout_width));
function force_odd(n) = 2*floor(n/2.0)+1;
function width_of_tiles(n,tile_width=tile_width(),grout_width=grout_width()) = n>0?n*(tile_width+grout_width)-grout_width:0;
function height_of_tiles(n,tile_height=tile_height(),grout_width=grout_width()) = width_of_tiles(n,tile_width=tile_height,grout_width=grout_width);

function floor_slope() = (1.0/16) / 12;

function bar_standoff() = inches(1);
function bar_height() = inches(36);
function bar_diameter() = inches(3.0/4);
function bar_z_offset() = inches(42);

function tile_color() = [0.75,0.75,0.7,tile_alpha];

module tile(height=tile_height(),width=tile_width(),thickness=tile_thickness(), color=tile_color(), ignore_small_height=false) {
    translate([0,-thickness,0]) color(color) {
        if (width < inches(1) || (!ignore_small_height && height < inches(1)) || thickness <= 0) {
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

module tile_row(columns=0,width=0,first_tile_width=0,last_tile_width=0,tile_width=tile_width(),tile_height=tile_height(),grout_width=grout_width(),tile_thickness=tile_thickness(),colors=[tile_color()],ignore_small_height=false) {
    effective_columns = columns != 0 ? columns : sign(width)*(let (rem=abs(width) - (first_tile_width==0?tile_width:first_tile_width) - grout_width) rem < 0 ? 1 : 1 + ceil(rem / (tile_width+grout_width)));
    effective_first_tile_width = let (x=(first_tile_width==0 ? tile_width : first_tile_width)) width==0 ? x : min(x,abs(width));
    effective_last_tile_width = let (x=(last_tile_width==0 ? tile_width : last_tile_width)) width==0 ? x : min(tile_width, abs(width)-effective_first_tile_width-grout_width-((abs(effective_columns)-2)*(tile_width+grout_width)));
    x_increment = tile_width+grout_width;
    first_column_offset=effective_first_tile_width+grout_width;
    translate([effective_columns<0?-effective_first_tile_width:0,0,0]) {
        tile(width=effective_first_tile_width,height=tile_height,thickness=tile_thickness,color=colors[0],ignore_small_height=ignore_small_height);
    }
    remaining_columns = abs(effective_columns) - 1;
    if (remaining_columns > 0) {
        translate([sign(effective_columns)*first_column_offset,0,0]) {
            for (column = [1:remaining_columns]) {
                translate([sign(effective_columns)*(column-1)*x_increment, 0, 0]) {
                    twidth=column<remaining_columns?tile_width:effective_last_tile_width;
                    translate([effective_columns<0?-twidth:0,0,0]) {
                        tile(width=twidth,height=tile_height,thickness=tile_thickness,color=colors[column%len(colors)],ignore_small_height=ignore_small_height);
                    }
                }
            }
        }
    }
}

module tile_grid(rows=0,columns=0,width=0,height=0,first_tile_width=0,last_tile_width=0,tile_width=tile_width(),first_tile_height=0,last_tile_height=0,tile_height=tile_height(),grout_width=grout_width(),tile_thickness=tile_thickness(),colors=[tile_color()]) {
    effective_rows = rows != 0 ? rows : sign(height)*(let (rem=abs(height) - (first_tile_height==0?tile_height:first_tile_height) - grout_width) rem < 0 ? 1 : 1 + ceil(rem / (tile_height+grout_width)));
    effective_first_tile_height = let (x=(first_tile_height==0 ? tile_height : first_tile_height)) height==0 ? x : min(x,abs(height));
    effective_last_tile_height = let (x=(last_tile_height==0 ? tile_height : last_tile_height)) height==0 ? x : min(tile_height, abs(height)-effective_first_tile_height-grout_width-((abs(effective_rows)-2)*(tile_height+grout_width)));
    translate([0,0,effective_rows<0?-effective_first_tile_height:0]) {
        tile_row(columns=columns,width=width,first_tile_width=first_tile_width,last_tile_width=last_tile_width,tile_width=tile_width,tile_height=effective_first_tile_height,grout_width=grout_width,tile_thickness=tile_thickness,colors=colors);
    }
    remaining_rows = abs(effective_rows) - 1;
    if (remaining_rows > 0) {
        translate([0,0,sign(effective_rows)*(effective_first_tile_height+grout_width)]) {
            for (row = [1:remaining_rows]) {
                translate([0, 0, sign(effective_rows)*(row-1)*(tile_height+grout_width)]) {
                    theight=row<remaining_rows?tile_height:effective_last_tile_height;
                    translate([0,0,effective_rows<0?-theight:0]) {
                        tile_row(columns=columns,width=width,first_tile_width=first_tile_width,last_tile_width=last_tile_width,tile_width=tile_width,tile_height=theight,grout_width=grout_width,tile_thickness=tile_thickness,colors=colors);
                    }
                }
            }
        }
    }
}

module accent_tile(width,length,seed=1) {
    if (true) {
//        tile_grid(width=width,height=length,tile_width=mm(75),tile_height=mm(300),colors=[[for (c=[207,227,243]) c/255.0]]);
        random_length_mosaic_tile(width,length,thickness=mm(8),grout_width=grout_width(),choices=[mm(300)],segment_width=mm(75),colors=[[for (c=[207,227,243]) c/255.0]],seed=seed);
    } else if (false) {
        fixed_length_interlocking_mosaic_tile(width,length,seed=seed);
    } else if (false) {
        random_length_mosaic_tile(width,length,thickness=inches(1.0/8),grout_width=inches(1.0/16),choices=[inches(1.5),inches(3),inches(4.5)],segment_width=inches(3.0/4),colors=[[0.0,0.05,0.4,accent_tile_alpha],[0.0,0.1,0.6,accent_tile_alpha]],seed=seed);
    } else {
        base_color=[for (x=[207,227,243]) x/255.0];
        random_length_mosaic_tile(width,length,thickness=mm(9),grout_width=mm(2),choices=[for (x=[5,10,15]) mm(x*10)-mm(2)],segment_width=mm(8),colors=[concat(base_color,[accent_tile_alpha]),concat(base_color,[accent_tile_alpha*0.8])],seed=seed);
/*

8mm wide

2mm grout

300mm wide

30 in 12"

lengths:
10 - grout
15 - grout
5 - grout
*/
    }
}

fixed_length_interlocking_mosaic_segment_length = inches(11+7.0/8);
fixed_length_interlocking_mosaic_pattern = [
        for (l=[[4+7.0/8, 5.0/8],
                [4, 3.0/4],
                [0, 3.0/4],
                [2, 2],
                [6, 5.0/8],
                [2, 5.0/8],
                [5+1.0/8, 5.0/8],
                [4, 3.0/4],
                [0, 3.0/4],
                [2+1.0/8, 2],
                [6, 5.0/8],
                [2, 5.0/8]])
            [for (x=l) inches(x)]
        ];
fixed_length_interlocking_mosaic_colors = [
        for (c=[[80,95,125],
                [207,227,243],
                [197,211,211]])
            [for (x=c) x/255.0]
        ];

module fixed_length_interlocking_mosaic_tile(width,length,pattern_index=0,width_offset=0,length_offset=0,seed=1) {
    thickness=inches(5.0/16);
    grout_width=inches(1.0/8);
    segment_length=fixed_length_interlocking_mosaic_segment_length;
    if (simplify_accent_tile) {
        color([0.0,0.1,0.6,accent_tile_alpha]) cube([width-grout_width,thickness,length]);
    } else {
        pattern_segment = fixed_length_interlocking_mosaic_pattern[pattern_index%len(fixed_length_interlocking_mosaic_pattern)];
        segment_offset = length_offset+pattern_segment[0];
        segment_width = pattern_segment[1];
        if (width_offset <= width) {
            first_tile_length = segment_offset <= 0 ? segment_length + segment_offset : segment_offset - grout_width;
            segments = let (rem=length - first_tile_length - grout_width) rem < 0 ? 1 : 1 + ceil(rem / (segment_length+grout_width));
            colors = [for (x=rands(min_value=0,max_value=len(fixed_length_interlocking_mosaic_colors),value_count=segments,seed=253*seed*(1+pattern_index))) fixed_length_interlocking_mosaic_colors[floor(x)]];
            translate([width_offset+segment_width,0,0]) rotate([0,-90,0]) tile_row(width=length,height=segment_width,first_tile_width=first_tile_length,tile_width=segment_length,tile_height=segment_width,grout_width=grout_width,tile_thickness=thickness,colors=colors,ignore_small_height=true);
            new_width_offset=width_offset+segment_width+grout_width;
            if (((2*pattern_index)%len(fixed_length_interlocking_mosaic_pattern))==0) {
                fixed_length_interlocking_mosaic_tile(width,length,pattern_index=pattern_index+1,width_offset=new_width_offset,length_offset=-segment_length*(.25+.5*floor(rands(min_value=0,max_value=1,value_count=1,seed=seed*25791)[0])),seed=seed*33);
            } else {
                fixed_length_interlocking_mosaic_tile(width,length,pattern_index=pattern_index+1,width_offset=new_width_offset,length_offset=length_offset,seed=seed);
            }
        }
    }
}


function generate_sequence_recur(target_length,choices,decision_index,decisions,grout_width,initial_offset) =
        decision_index == (len(decisions) - 2)
        ? let (choice=initial_offset*choices[floor(decisions[decision_index]*len(choices))]) [[0, 0, min(choice,target_length)]]
        : ( let (seq=generate_sequence_recur(target_length,choices,decision_index+1,decisions,grout_width,initial_offset))
            let (length=seq[0][1] + seq[0][2])
            length >= target_length ? seq
            : ( let (remaining_choices=[for (c=choices) if (len(choices)==1||c!=seq[0][2]) c])
                let (choice=remaining_choices[floor(decisions[decision_index]*len(remaining_choices))])
                concat([[1+seq[0][0],length+grout_width,min(target_length-length-grout_width,choice)]],seq)));

function generate_sequence(length,choices,grout_width,initial_offset,seed) = generate_sequence_recur(target_length=length,choices=choices,decision_index=0,decisions=rands(min_value=0.0,max_value=1.0,value_count=2+ceil(length/min(choices)),seed),grout_width=grout_width,initial_offset=initial_offset);

module random_length_mosaic_tile(width,length,choices,colors,thickness,grout_width,segment_width,seed=0) {
    translate([0,-tile_thickness(),0]) {
        if (simplify_accent_tile) {
            color(colors[0]) cube([width,thickness,length]);
        } else {
            union() {
                columns = floor((width+grout_width)/(segment_width+grout_width));
//                z_offsets = max(choices)*(.25+.5*floor(rands(min_value=0,max_value=2,value_count=columns,seed=seed*287)));
                for (column=[0:columns-1]) {
                    sequence=generate_sequence(length=length,choices=choices,grout_width=grout_width,initial_offset=[.33,0,.66][column%3],seed=seed*8971*(1+column));
                    echo(length=length,choices=choices,grout_width=grout_width,seed=seed*897*(1+column));
                    echo(seq1=sequence[0],seq2=sequence[1]);
                    segment_colors = [for (x=rands(min_value=0,max_value=len(colors),value_count=len(sequence),seed=seed*253*(1+column))) floor(x)];
                    for (segment=sequence) {
                        segment_index=segment[0];
                        segment_offset=segment[1];
                        segment_length=segment[2];
                        translate([column*(segment_width+grout_width),0,segment_offset]) {
                            color(colors[segment_colors[segment_index]]) {
                                cube([segment_width,thickness,segment_length]);
                            }
                        }
                    }
                }
            }
        }
    }
}

module shower_cubby(width,height,first_tile_width=0,first_tile_height=0,depth=inches(3.5),omit_back_wall=false,seed=3,grout_inside_top=false,grout_inside_left=false,grout_inside_right=false,grout_inside_bottom=false) {
    adjusted_first_tile_height=first_tile_height==0?0:min(max(tile_height(),tile_width()),first_tile_height-grout_width()+(height<=(first_tile_height+grout_width())?tile_thickness():0));
    shelf_overhang=inches(1.0/8);

    // shelf
    translate([grout_width(),-tile_thickness()-shelf_overhang,grout_width()]) {
        rotate([-90,0,0]) tile_grid(width=width-2*grout_width(),height=depth-grout_width()+shelf_overhang,first_tile_width=(first_tile_width==0?tile_width():first_tile_width));
    }

    // ceiling
    translate([grout_width(),depth-(grout_inside_top?0:tile_thickness()+grout_width()),height+tile_thickness()]) {
        rotate([90,0,0]) tile_grid(width=width-2*grout_width(),height=depth-grout_width()-(grout_inside_top?0:tile_thickness()+grout_width()),first_tile_width=(first_tile_width==0?tile_width():first_tile_width));
    }

    if (!omit_back_wall) {
        // back
        translate([grout_inside_left?grout_width():-tile_thickness(),depth,grout_width()]) {
            if (!accent_cubby) {
                tile_grid(width=width+(grout_inside_left?-grout_width():tile_thickness())+(grout_inside_right?-grout_width():tile_thickness()),height=height+(grout_inside_bottom?-grout_width():0)+(grout_inside_top?-grout_width():tile_thickness()-grout_width()),first_tile_width=(first_tile_width==0?tile_width():first_tile_width)+tile_thickness(),first_tile_height=adjusted_first_tile_height);
            } else {
                if (accent_tile_vertical) {
                    accent_tile(width=width+2*tile_thickness(),length=height+tile_thickness(),seed=seed*223);
                } else {
                    translate([0,0,height+tile_thickness()]) rotate([0,90,0]) accent_tile(length=width+2*tile_thickness(),width=height+tile_thickness(),seed=seed*991);
                }
            }
        }
    }

    side_tile_height=max(tile_height(),tile_width());
    side_tile_width=min(tile_height(),tile_width());

    // left
    translate([-tile_thickness(),grout_width(),grout_width()]) {
        rotate([0,0,90]) tile_grid(width=depth-tile_thickness()-2*grout_width()+(grout_inside_left?grout_width()+tile_thickness():0),height=height+tile_thickness()-grout_width(),first_tile_height=adjusted_first_tile_height,tile_width=side_tile_width,tile_height=side_tile_height);
//        echo(width=depth-tile_thickness()-2*grout_width()+(grout_inside_left?grout_width()+tile_thickness():0),height=height+tile_thickness()-grout_width(),first_tile_height=adjusted_first_tile_height,tile_width=side_tile_width,tile_height=side_tile_height);
    }

    // right
    translate([width+tile_thickness(),depth-tile_thickness()-grout_width()+(grout_inside_left?grout_width()+tile_thickness():0),grout_width()]) {
        rotate([0,0,-90]) tile_grid(width=depth-tile_thickness()-2*grout_width()+(grout_inside_right?grout_width()+tile_thickness():0),height=height+tile_thickness()-grout_width(),first_tile_height=adjusted_first_tile_height,tile_width=side_tile_width,tile_height=side_tile_height);
    }
}
