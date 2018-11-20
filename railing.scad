use <math.scad>;

$fn = 10;

function feet( x) = inches( x) * 12;
function inches( x) = x;

function top_rail_height() = inches(2);
function top_rail_width() = inches(2);

function bottom_rail_height() = inches(2);
function bottom_rail_width() = inches(2);

function baluster_diameters() = [for (i=[5]) i*inches(1.0/16)];
function baluster_angle_offsets() = [-2,-1,0,1,2];
//function baluster_angle_offsets() = [0];
function baluster_quantum() = inches(1.5);
//function baluster_quantum() = inches(3);
//function baluster_max_gap() = floor(inches(2)/baluster_quantum());
function baluster_max_gap() = 1;
function baluster_socket_depth() = inches(1);

function walnut() = [0.247, 0.165, 0.078];

module railing( span, height, angle, seed) {
    // balusters
    translate([0,0,bottom_rail_height()+(height-top_rail_height()-bottom_rail_height())/2]) {
        color("black",0.5) balusters( span=span, height=height-top_rail_height()-bottom_rail_height(), angle=angle, seed=seed*248537);
    }

    // top rail
    translate([0,-top_rail_width()/2,height-top_rail_height()]) {
        color(walnut(),0.5) cube([span,top_rail_width(),top_rail_height()]);
    }

    // bottom rail
    translate([0,-bottom_rail_width()/2,0]) {
        color(walnut(),0.5) cube([span,bottom_rail_width(),bottom_rail_height()]);
    }

    echo(slots=span/baluster_quantum());
}

module balusters( span, height, angle, seed) {
    slots = let (n=floor(span/baluster_quantum())) (span-(n*baluster_quantum())) > 0 ? n : n;
    translate([(span-(slots*baluster_quantum()))/2,0,0]) {
        balusters_recur( height, angle, top_bitmap=[for (i=[0:slots-1]) undef], bottom_bitmap=[for (i=[0:slots-1]) undef], seed=seed);
    }
}

function v_cat(v,i=0) = i<len(v) ? concat(v[i], v_cat(v,i+1)) : [];

function scale2int(x, min_int, max_int) = min_int+floor(x*(max_int-min_int));
function choice(x, v) = v[scale2int(x,0,len(v))];
function v_set(v,i,x) = [for (j=[0:len(v)-1]) j==i?x:v[j]];

function constrain_choices2(choices, top_bitmap, bottom_bitmap) = [for (c=choices) if (choiceok(c[0],c[1],top_bitmap,bottom_bitmap)) c];
function slotavail(i,bitmap) = i>=0 && i<len(bitmap) && bitmap[i] == undef;
function topslot(origin,angle) = origin+angle;
function bottomslot(origin,angle) = origin;
function choiceok(origin, angle, top_bitmap, bottom_bitmap) = slotavail(topslot(origin,angle),top_bitmap) && slotavail(bottomslot(origin,angle),bottom_bitmap);

function find_gaps(bitmap, i=0, start=undef) = (
        i < len(bitmap)
        ? (bitmap[i] == undef
           ? find_gaps(bitmap, i+1, start=(start != undef?start:i))
           : (start != undef
              ? concat([[start, i-1]], find_gaps(bitmap, i+1))
              : find_gaps(bitmap, i+1)))
        : (start != undef ? [[start, i-1]] : []));

function rv(n,seed) = rands(0,1,n,seed*9876543333);
function find_largest_gap(gaps, i=1, li=0, seed) = (
        i < len(gaps)
        ? ( let (g=gaps[i], s=g[1]-g[0], lg=gaps[li], ls=lg[1]-lg[0], rv=rv(2,seed))
            find_largest_gap(gaps, i+1, li=(ls>s?li:(s>ls?i:(rv[0]<0.5?i:li))), seed=rv[1]))
        : li);

module balusters_recur( height, railing_angle, top_bitmap, bottom_bitmap, seed) {
    echo(top=top_bitmap);
    echo(bot=bottom_bitmap);

    top_gaps = [for (g=find_gaps(top_bitmap)) if ((1+g[1]-g[0]) > baluster_max_gap()) g];
    bottom_gaps = [for (g=find_gaps(bottom_bitmap)) if ((1+g[1]-g[0]) > baluster_max_gap()) g];
    echo(gapcount=len(find_gaps(bottom_bitmap)));

    balusters_recur2( height, railing_angle, top_gaps, bottom_gaps, top_bitmap, bottom_bitmap, seed);
}

module balusters_recur2( height, railing_angle, top_gaps, bottom_gaps, top_bitmap, bottom_bitmap, seed) {

    if (len(top_gaps) > 0 || len(bottom_gaps) > 0) {
        rv = rv(10,seed);

        largest_top_gap_i = find_largest_gap(top_gaps,rv[0]);
        largest_top_gap = top_gaps[largest_top_gap_i];
        largest_top_gap_size = largest_top_gap[1] - largest_top_gap[0];
        echo(top_gaps=top_gaps);
        echo(top_gaps=[for (g=top_gaps) 1+g[1]-g[0]]);

        largest_bottom_gap_i = find_largest_gap(bottom_gaps,rv[1]);
        largest_bottom_gap = bottom_gaps[largest_bottom_gap_i];
        largest_bottom_gap_size = largest_bottom_gap[1] - largest_bottom_gap[0];
        echo(bot_gaps=[for (g=bottom_gaps) 1+g[1]-g[0]]);
        echo(bot_gaps=bottom_gaps);

        use_bottom = len(top_gaps) == 0 || largest_bottom_gap_size > largest_top_gap_size || (largest_bottom_gap_size == largest_top_gap_size && rv[2]<0.5);

        choices = use_bottom
                ? [for (angle=baluster_angle_offsets()) [floor((1 + largest_bottom_gap[0] + largest_bottom_gap[1])/2.0), angle]]
                : [for (angle=baluster_angle_offsets()) [floor((1 + largest_top_gap[0] + largest_top_gap[1])/2.0)-angle, angle]];

        echo(choices=choices);
        candidates=constrain_choices2(choices, top_bitmap, bottom_bitmap);
        echo(candidates=candidates);
        if (len(candidates)>0) {
            gap_angles = use_bottom ? [for (i=largest_bottom_gap) bottom_bitmap[i]] : [for (i=largest_top_gap) -top_bitmap[i]];
            echo(gap_angles=gap_angles, largest_bottom_gap=largest_bottom_gap, largest_top_gap=largest_top_gap);
            preferred_choice = choice(rv[3], [for (c=candidates) if (c[1] != gap_angles[0] && c[1] != gap_angles[1]) c]);
            echo(preferred_choice=preferred_choice);
            slot_angle = preferred_choice != undef ? preferred_choice : choice(rv[4], candidates);
            echo(slot_angle=slot_angle);
            slot = slot_angle[0];
            bangoff = slot_angle[1];
            diameter = choice(rv[5], baluster_diameters());
            translate([(slot+bangoff/2)*baluster_quantum(),0,0]) {
                a=atan(bangoff*baluster_quantum()/height);
//            echo(height=height, bangoff=bangoff, a=a);
                rotate([0,a,0]) {
                    cylinder(d=diameter,h=(height+2*baluster_socket_depth())/cos(a),center=true);
                }
            }
            balusters_recur(
                    height=height,
                    railing_angle=railing_angle,
                    top_bitmap=v_set(top_bitmap,topslot(slot,bangoff),-bangoff),
                    bottom_bitmap=v_set(bottom_bitmap,bottomslot(slot,bangoff),bangoff),
                    seed=rv[6]);
        } else {
            balusters_recur2(
                    height=height,
                    railing_angle=railing_angle,
                    top_gaps=use_bottom?top_gaps:[for (i=[0:len(top_gaps)-1]) if (i!=largest_top_gap_i) top_gaps[i]],
                    bottom_gaps=!use_bottom?bottom_gaps:[for (i=[0:len(bottom_gaps)-1]) if (i!=largest_bottom_gap_i) bottom_gaps[i]],
                    top_bitmap=top_bitmap,
                    bottom_bitmap=bottom_bitmap,
                    seed=rv[7]);
        }
    } else {
        for (g=[for (g=find_gaps(top_bitmap)) if ((g[1]-g[0])>=(baluster_max_gap()-1)) g]) {
            translate([(g[0]+g[1])*baluster_quantum()/2,0,height/2-inches(2)]) {
                echo(leftover=g);
                color("black",0.001) sphere(r=inches(2),$fn=30);
            }
        }
    }
}


railing(span=inches(120),height=inches(38-3),angle=0,seed=828);
