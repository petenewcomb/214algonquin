use <math.scad>;

$fn = 12;

function _echo(x,s) = [x, search([str(s)], [])][0];
function _assert(m,x,v) = x?v:_echo(v, str(m));
function _value(n,v) = _echo(v, str(n,"=",v));
function _func(n,a) = _echo(undef, str(n,"(",_args(a),")"));
function _args(a,i=0,s="") = i>=len(a)?s:_args(a,i+2,i==0?str(a[0],"=",a[1]):str(s,", ",a[i],"=",a[i+1]));

function feet(ft,in=0) = inches(ft*12+in);
function inches(in) = in;

function max_tilt_offset() = 3;
function horizontal_resolution() = inches(1);
function vertical_resolution() = horizontal_resolution();
function max_gap() = inches(3+3/8);
function railing_height() = inches(38);
function railing_bottom_gap() = inches(3.5);
function vertical_span() = railing_height()-railing_bottom_gap()-top_rail_height()-bottom_rail_height();
function intersection_density() = 1/3;

function post_width() = inches(8);
function post_height() = inches(42);
function top_rail_height() = inches(1+1/2);
function top_rail_width() = inches(3);
function bottom_rail_height() = inches(1+1/2);
function bottom_rail_width() = inches(3);
function baluster_diameter() = inches(3/8);
function baluster_socket_depth() = min(top_rail_height(),bottom_rail_height())/2;
function walnut() = [0.247, 0.165, 0.078];

function rv(n,seed) = seed == undef ? rands(0,1,n) : rands(0,1,n,seed<1?seed*274247292924:seed);

function v_cat(v,i=0) = i<len(v) ? concat(v[i], v_cat(v,i+1)) : [];
function v_sum(v, start=0, end=undef, sum=0) =
        start >= len(v) || (end != undef && start >= end)
        ? sum
        : v_sum(v, start + 1, end, sum+(start<0||start>=len(v)?0:v[start]));
function v_std(v,avg=undef) = len(v) <= 1 ? 0 : let(a=avg!=undef?avg:v_avg(v)) sqrt(v_sum([for (x=v) let(d=x-a) d*d])/(len(v)-1));
function v_avg(v) = len(v) == 0 ? 0 : v_sum(v)/len(v);
function v_max(v, i=0, m=undef) = i >= len(v) ? m : v_max(v, i+1, m==undef?v[i]:max(v[i], m));
function v_set(v,i,x) = [for (j=[0:len(v)-1]) j==i?x:v[j]];

function tuples(k, v, i=0, result=[]) =
        (i + k) > len(v)
        ? result
        : tuples(k, v, i+1, concat(result, [[for (j=[i:i+k-1]) v[j]]]));

function scale2int(x, min_int, max_int) = min_int+floor(x*(max_int-min_int));
function choice(x, v) = v[scale2int(x,0,len(v))];
function weighted_choice(x, v) = weighted_choice_recur(x, vquicksort(0, v), v_sum([for (i=v) i[0]]), len(v)-1);
function weighted_choice_recur(x, v, total, i) = let(w=v[i][0]/total) x<=w ? v[i][1] : weighted_choice_recur(x-w, v, total, i-1);

// input : list of numbers
// output : sorted list of numbers
function quicksort(arr) = !(len(arr)>0) ? [] : let(
    pivot   = arr[floor(len(arr)/2)],
    lesser  = [ for (y = arr) if (y  < pivot) y ],
    equal   = [ for (y = arr) if (y == pivot) y ],
    greater = [ for (y = arr) if (y  > pivot) y ]
) concat(
    quicksort(lesser), equal, quicksort(greater)
);

// input : list of vectors
// output : list of vectors sorted by element i
function vquicksort(i, arr) = !(len(arr)>0) ? [] : let(
    pivot   = arr[floor(len(arr)/2)][i],
    lesser  = [ for (y = arr) if (y[i]  < pivot) y ],
    equal   = [ for (y = arr) if (y[i] == pivot) y ],
    greater = [ for (y = arr) if (y[i]  > pivot) y ]
) concat(
    vquicksort(i, lesser), equal, vquicksort(i, greater)
);

function vgroupby(k, v, i=0, result=[]) =
        i >= len(v) ? result
        : vgroupby(k, v, i+1,
                   let(p = len(result)==0 ? undef : result[len(result)-1],
                       n = v[i])
                   p == undef || p[0][k] != n[k]
                   ? concat(result, [[n]])
                   : v_set(result, len(result)-1, concat(p, [n])));

function balusters_hspan(b) = b[0];
function balusters_vspan(b) = b[1];
function balusters_hres(b) = b[2];
function balusters_vres(b) = b[3];
function balusters_max_tilt_offset(b) = b[4];
function balusters_max_gap(b) = b[5];
function balusters_initial_seed(b) = b[6];
function balusters_next_seed(b) = b[7];
function balusters_rods(b) = b[8];
function balusters_bottom_map(b) = b[9];
function balusters_top_map(b) = b[10];

function balusters_maps(b) = [balusters_bottom_map(b), balusters_top_map(b)];
function balusters_max_tilt(b) = balusters_tilt(b, balusters_max_tilt_offset(b));
function balusters_tilt(b, o) = atan(o*balusters_hres(b)/balusters_vspan(b));
function balusters_max_spacing(b) = balusters_max_gap(b)+baluster_diameter();

function balusters_new(hspan, vspan, hres=horizontal_resolution(), vres=vertical_resolution(), max_tilt_offset=max_tilt_offset(), max_gap=max_gap(), initial_seed=undef, next_seed=undef) =
        let(is=initial_seed!=undef?initial_seed:floor(rands(0,1000000,1)[0]),
            ns=next_seed!=undef?next_seed:rv(1,is)[0],
            slots=floor(hspan/hres), // leaves at least hres/2 for margins
            empty_map = [for (i=[0:slots-1]) undef])
        [hspan, vspan, hres, vres, max_tilt_offset, max_gap, is, ns, [], empty_map, empty_map];

function balusters_dump(b) = [
        balusters_hspan(b),
        balusters_vspan(b),
        balusters_hres(b),
        balusters_vres(b),
        balusters_max_tilt_offset(b),
        balusters_max_gap(b),
        balusters_initial_seed(b),
        balusters_next_seed(b),
        [for (r=vquicksort(0,balusters_rods(b))) [r[0]+1, r[1]+1]]];

function balusters_load(b) = balusters_load_recur(
        balusters_new(
                hspan=balusters_hspan(b),
                vspan=balusters_vspan(b),
                hres=balusters_hres(b),
                vres=balusters_vres(b),
                max_tilt_offset=balusters_max_tilt_offset(b),
                max_gap=balusters_max_gap(b),
                initial_seed=balusters_initial_seed(b),
                next_seed=balusters_next_seed(b)),
        balusters_rods(b));
function balusters_load_recur(b, rods, i=0) =
        i>=len(rods) ? b : balusters_load_recur(balusters_add(b, balusters_next_seed(b), [for (s=rods[i]) s-1]), rods, i+1);

function balusters_margin(b) =
        let(hspan = balusters_hspan(b),
            hres = balusters_hres(b),
            slots = len(balusters_bottom_map(b)))
        (hspan-hres*(slots-1))/2;

function balusters_check_rod(b, rod) =
        let(maps=balusters_maps(b),
            tests=[for (i=[0,1]) let(r=rod[i],m=maps[i]) 0 <= r && r < len(m) && m[r] == undef])
        tests[0] && tests[1];

function balusters_add(b, next_seed, rod) =
        let(rods=balusters_rods(b))
        concat([balusters_hspan(b),
                balusters_vspan(b),
                balusters_hres(b),
                balusters_vres(b),
                balusters_max_tilt_offset(b),
                balusters_max_gap(b),
                balusters_initial_seed(b),
                next_seed,
                concat(rods,[rod])],
               let(maps=balusters_maps(b),
                   l=len(rods))
               [for (i=[0,1]) v_set(maps[i],rod[i],len(rods))]);

function balusters_remove(b, next_seed, rod) =
//        let(_f=_func("balusters_remove",["b",b,"next_seed",next_seed,"rod",rod]))
        concat([balusters_hspan(b),
                balusters_vspan(b),
                balusters_hres(b),
                balusters_vres(b),
                balusters_max_tilt_offset(b),
                balusters_max_gap(b),
                balusters_initial_seed(b),
                next_seed,
                [for (r=balusters_rods(b)) if (r!=rod) r]],
               (let(maps=balusters_maps(b))
                [for (i=[0,1]) v_set(maps[i],rod[i],undef)]));

// Vector of crossings at each level dictated by vres, as vectors of [x, y, rod_index] in ascending order of x position.
function balusters_crossings(b, diameter=baluster_diameter(), i=0, result=[]) =
        let(//_f=(i==0?_func("balusters_crossings",["b",b,"diameter",diameter,"i",i,"result",result]):0),
            vspan = balusters_vspan(b),
            vres = balusters_vres(b),
            n = round(vspan/vres),
            evres = vspan/n)
        i > n ? result
        : balusters_crossings(
                b, diameter, i+1,
                concat(result,
                       [let(margin = balusters_margin(b),
                            hres = balusters_hres(b),
                            y = i*evres,
                            rods = balusters_rods(b))
                        concat([[-diameter/2, y, -1]],
                               len(rods) == 0 ? [] : vquicksort(0, [for (ri=[0:len(rods)-1]) let(r=rods[ri]) [margin + hres*r[0] + hres*(r[1]-r[0])*y/vspan, y, ri]]),
                               [[balusters_hspan(b)+diameter/2, y, len(rods)]])]));

// Gaps in a set of balusters, as a vector of horizontal rows of [[min_x, max_x, y], [min_rod_index, max_rod_index]]
function balusters_hgaps(b, diameter=baluster_diameter()) =
        [for (c=balusters_crossings(b, diameter))
                [for (t=tuples(2,c))
                        let (a=t[0],b=t[1])
                                [[a[0]+diameter/2, b[0]-diameter/2, a[1]], [a[2], b[2]]]]];

// Gaps in a set of balusters, as a vector of vertical columns of [[min_x, max_x, y], [min_rod_index, max_rod_index]]
function balusters_vgaps(b, diameter=baluster_diameter()) =
        let(hgaps=balusters_hgaps(b, diameter=diameter))
        [for (i=[0:len(hgaps[0])-1]) [for (hg=hgaps) hg[i]]];

// Aggregates hgaps in a vertical column into a vector of [[[min_x, max_x, min_y], ... [min_x, max_x, max_y]], [min_rod_index, max_rod_index]]
function aggregate_vgaps(v, min_gap=0, i=0, result=[]) =
        i >= len(v)
        ? result
        : aggregate_vgaps(v, min_gap, i+1,
                let(n = v[i],
                    nc = n[0])
                (nc[1]-nc[0]) <= min_gap
                ? result
                : (let(p = len(result)==0 ? undef : result[len(result)-1],
                       nr = n[1])
                   p == undef || p[1] != nr
                   ? concat(result, [[[nc], nr]])
                   : v_set(result, len(result)-1, [concat(p[0], [nc]), nr])));

// Gaps in a set of balusters, as a vector of vertical columns of [[[min_x, max_x, min_y], ... [min_x, max_x, max_y]], [min_rod_index, max_rod_index]]
function balusters_aggregate_vgaps(b, diameter=baluster_diameter(), min_gap=undef) =
        let(emin_gap = min_gap!=undef?min_gap:balusters_max_gap(b))
        [for (vg=balusters_vgaps(b, diameter=diameter))
                [for (ag=aggregate_vgaps(vg, min_gap=emin_gap)) if ((ag[0][len(ag[0])-1][2]-ag[0][0][2])>emin_gap) ag]];

// Gaps in a set of balusters, as a vector of [area, [[min_x, max_x, min_y], ... [min_x, max_x, max_y]], [min_rod_index, max_rod_index]]
function balusters_gaps(b, diameter=baluster_diameter(), min_gap=undef, i=0, result=[]) =
        let(vres = balusters_vres(b))
        [for (avg=balusters_aggregate_vgaps(b, diameter=diameter, min_gap=min_gap))
                for (ag=avg) concat([v_sum([for (g=ag[0]) (g[1]-g[0])*vres])], ag)];

function fill_smallest_gap(b, gaps) =
        let(_f=_func("fill_smallest_gap",["b",b]),
            gap = gaps[0],
            rv = rv(5,balusters_next_seed(b)),
            hres = balusters_hres(b),
            vspan = balusters_vspan(b),
            bot = gap[1][0],
            top = gap[1][len(gap[1])-1],
            gap_min_x = (bot[0]+top[0])/2,
            gap_max_x = (bot[1]+top[1])/2,
            gap_x = (gap_min_x+gap_max_x)/2,
            gap_y = (bot[2]+top[2])/2,
            margin = balusters_margin(b),
            max_tilt_offset = balusters_max_tilt_offset(b),
            tilt_offset_slopes = [for (to=[-max_tilt_offset:max_tilt_offset]) if (to!=0) [to, to*hres/vspan]],
            tilt_offset_bottom_intercepts = [for (tos=tilt_offset_slopes) [tos[0], gap_x-gap_y*tos[1]]],
//            rod_offsets = [for (i=[-1,1]) 
            candidate_rods = [for (tobi=tilt_offset_bottom_intercepts) let(bottom_slot=round((tobi[1]-margin)/hres)) [bottom_slot, bottom_slot+tobi[0]]],
            valid_rods = [for (cr=candidate_rods) if (balusters_check_rod(b, cr)) cr],
            rrv = rv(len(valid_rods),seed=rv[0]),
            candidates = len(valid_rods) == 0 ? [] : [for (i=[0:len(valid_rods)-1]) balusters_add(b, rrv[i], valid_rods[i])],
            scored_candidates = vquicksort(0, [for (c=randomize(candidates,rv[1])) [balusters_score(c), c]]))
        len(scored_candidates) == 0 ? undef : randomize([for (i=[0:min(len(scored_candidates),1)]) scored_candidates[i][1]],rv[2])[0];

function remove_rod(b) =
        let(_f=_func("remove_rod",["b",b]),
            rv = rv(2,balusters_next_seed(b)),
            rods = balusters_rods(b),
            candidate_rods = let(rr=randomize(rods,rv[0])) [for (i=[0:min(len(rr),10)-1]) rr[i]], // TODO: be targeted about selecting candidates
            rrv = rv(len(candidate_rods),seed=rv[1]),
//            lookahead = 0,
            candidates = [
                    for (i=[0:len(candidate_rods)-1])
                        let(b2=balusters_remove(b, rrv[i], candidate_rods[i])
//                            gaps=vquicksort(0,balusters_gaps(b2)),
//                            b3 = _value("b3",(len(gaps)==0 ? b2
//                                  : _value("flg",fill_largest_gap(b2, gaps)))))
                            )
                                b2])
        vquicksort(0, [for (c=candidates) [balusters_score(c), c]])[0][1];

function fill_gaps(b) =
        let(_f=_func("fill_gaps",["b",b]),
            gaps = vquicksort(0,balusters_gaps(b)),
            score = _value("score",balusters_score(b)),
            len_gaps = _value("len(gaps)",len(gaps)),
            rods = balusters_rods(b),
            maps = balusters_maps(b),
            hres = balusters_hres(b),
            hspan = balusters_hspan(b),
            max_gap = balusters_max_gap(b),
            diameter = baluster_diameter(),
            margin = balusters_margin(b),
            max_balusters = ceil(2*(hspan-2*margin)/(max_gap+diameter)),
            fill = _value("fill",len(rods)/max_balusters),
            b2 = len(gaps) == 0 && score <= 0 ? b : (len(rods) < max_balusters ? (let(b3=fill_smallest_gap(b, gaps)) b3 != undef ? b3 : remove_rod(b)) : remove_rod(b)))
        b2 == b ? b : fill_gaps(b2);

/*
function fill_largest_gap(b) =
        let(_f=_func("fill_gaps",["b", b, "gaps", gaps]),
            gaps = _value("gaps",balusters_gaps(b)),
            rv = rv(5,balusters_next_seed(b)),
            rods = balusters_rods(b),
            maps = balusters_maps(b),
            hres = balusters_hres(b),
            max_gap = balusters_max_gap(b),
            max_balusters = ceil(len(maps[0])/floor(0.75*max_gap/hres)),
            gap = let(sg=vquicksort(0, gaps)) sg[len(sg)-1],
            vspan = balusters_vspan(b),
            vres = balusters_vres(b),
            bot = gap[1],
            top = gap[2],
            gap_x = ((bot[0]+bot[1])/2 + (top[0]+top[1])/2) / 2,
            gap_y = (bot[2]+top[2])/2,
            hspan = balusters_hspan(b),
            margin = balusters_margin(b),
            max_tilt_offset = balusters_max_tilt_offset(b),
            tilt_offset_slopes = [for (to=[-max_tilt_offset:max_tilt_offset]) if (to!=0) [to, to*hres/vspan]],
            tilt_offset_bottom_intercepts = [for (tos=tilt_offset_slopes) [tos[0], gap_x-gap_y*tos[1]]],
            candidate_rods = [for (tobi=tilt_offset_bottom_intercepts) let(bottom_slot=round((tobi[1]-margin)/hres)) [bottom_slot, bottom_slot+tobi[0]]],
            valid_rods = _value("valid_rods",[for (cr=candidate_rods) if (balusters_check_rod(b, cr)) cr]),
            rrv = _value("rrv",rv(len(valid_rods),seed=rv[0])),
            lookahead = 0,
            candidates = len(valid_rods) == 0 ? [] : [for (i=[0:len(valid_rods)-1]) fill_gaps(balusters_add(b, rrv[i], valid_rods[i]),maxdepth=lookahead,depth=depth+1)])
        maxdepth == 0 || (len(gaps) == 0 && score <= 0)
        ? _value("done",[score, b]) // done
        : _value("next",fill_gaps(
                (len(rods) >= max_balusters || len(valid_rods) == 0
                 // backtrack by removing a rod
                 ? remove_rod(b, seed=rv[0], depth=depth+1)
                 // add a rod to fill the largest gap
                 : vquicksort(0,candidates)[0]),
                maxdepth=maxdepth-1,
                depth = depth+1));
*/


module balusters_report(b) {
    hres = balusters_hres(b);
    margin = balusters_margin(b);
    hspan = balusters_hspan(b);
    vspan = balusters_vspan(b);
    max_gap = balusters_max_gap(b);
    max_spacing = balusters_max_spacing(b);
    rods = balusters_rods(b);

    echo(hspan=hspan);
    echo(vspan=vspan);
    echo(hres=hres);
    echo(vres=balusters_vres(b));
    echo(max_tilt_offset=balusters_max_tilt_offset(b));
    echo(initial_seed=balusters_initial_seed(b));
    echo(next_seed=balusters_next_seed(b));
    echo(max_gap=max_gap);

    echo(max_tilt=balusters_max_tilt(b));
    echo(margin=margin);
    echo(max_spacing=max_spacing);

    echo(rods=len(rods));
    echo(slots=[for (m=balusters_maps(b)) len(m)]);
    echo(lengths=[for (m=balusters_maps(b)) hres*(len(m)-1)+2*margin]);

    socket_depth=baluster_socket_depth();

    for (o=[1:balusters_max_tilt_offset(b)]) {
//        rod_length=let(x=hres*o,y=vspan+2*socket_depth) sqrt(x*x+y*y);
        rod_length=let(x=hres*o,y=vspan+2*socket_depth) norm([x,y]);//-sqrt(x*x+y*y);
        rod_length_inches=floor(rod_length);
        rod_lengths_eights=floor(8*(rod_length-rod_length_inches));
        rod_count=len([for (r=rods) if (abs(r[1]-r[0])==o) r]);
        echo(rod_tilt=o,rod_count=rod_count,rod_length=rod_length); //str(rod_length_inches,rod_lengths_eights>0?str(rod_lengths_eights,"/8"):""));
    }

    score_terms = balusters_score(b, debug=true);
    for (i=[0:2:len(score_terms)-1]) {
        echo("score:",name=score_terms[i],value=score_terms[i+1]);
    }

    gaps = balusters_gaps(b);
    if (len(gaps) > 0) {
        for (g=[for (i=[max(0,len(gaps)-5):len(gaps)-1]) gaps[i]]) {
            echo(g=g);
        }
    }
}

module balusters(b,socket_depth=baluster_socket_depth(),cubes=false,show_gaps=false) {
    hres = balusters_hres(b);
    margin = balusters_margin(b);
    hspan = balusters_hspan(b);
    vspan = balusters_vspan(b);
    max_gap = balusters_max_gap(b);
    max_spacing = balusters_max_spacing(b);
    rods = balusters_rods(b);

    // balusters
    translate([margin, 0, 0]) {
        for (r=rods) {
            translate([r[0]*hres, 0, 0]) {
                a = atan((r[1]-r[0])*hres/vspan);
                rotate([0, a, 0]) {
                    socket_depth = baluster_socket_depth()/cos(a);
                    translate([0, sign(a)*baluster_diameter()/2, -socket_depth]) {
                        color("black",0.5) {
                            if (cubes) {
                                translate([-baluster_diameter()/2,-baluster_diameter()/2,0]) {
                                    cube([baluster_diameter(), baluster_diameter(), vspan/cos(a)+2*socket_depth]);
                                }
                            } else {
                                cylinder(d=baluster_diameter(), h=vspan/cos(a)+2*socket_depth, center=false);
                            }
                        }
                    }
                }
            }
        }
    }

    if (show_gaps) {
        gaps = vquicksort(0,balusters_gaps(b));
        if (len(gaps) > 0) {
            for (g=[for (i=[max(0,len(gaps)-5):len(gaps)-1]) gaps[i]]) {
                if (g[0]>max_gap) {
                    translate([g[1],0,g[2]]) {
                        color(g[0]>max_gap?"red":"black",0.3) sphere(r=inches(2),$fn=30);
                    }
                }
            }
        }
    }
}

module railing(b) {
    hres = balusters_hres(b);
    margin = balusters_margin(b);
    hspan = balusters_hspan(b);
    vspan = balusters_vspan(b);
    max_gap = balusters_max_gap(b);
    max_spacing = balusters_max_spacing(b);
    rods = balusters_rods(b);

    translate([0, 0, bottom_rail_height()]) {
        balusters(b,show_gaps=true);
    }

    // top rail
    translate([0, -top_rail_width()/2, bottom_rail_height()+vspan]) {
        color(walnut(),0.8) cube([hspan,top_rail_width(),top_rail_height()]);
    }

    // bottom rail
    translate([0,-bottom_rail_width()/2,0]) {
        color(walnut(),0.8) cube([hspan,bottom_rail_width(),bottom_rail_height()]);
    }

    // left post
    translate([-post_width(),-post_width()/2,-inches(3)]) {
        color(walnut(),0.8) cube([post_width(),post_width(),post_height()]);
    }

    // right post
    translate([hspan,-post_width()/2,-inches(3)]) {
        color(walnut(),0.8) cube([post_width(),post_width(),post_height()]);
    }
}

function balusters_score(b,debug=false) =
        let(//_f=_func("balusters_score",["b",b,"debug",debug]),
            gaps = balusters_gaps(b, diameter=0, min_gap=0),
            hgaps = balusters_hgaps(b, diameter=0),
            avgaps = balusters_aggregate_vgaps(b, diameter=0, min_gap=0),
            vres = balusters_vres(b),
            rods = balusters_rods(b),
            bias = len(rods)==0?0:v_sum([for (r=rods) r[1]-r[0]])/len(rods),
            hspan = balusters_hspan(b),
            hres = balusters_hres(b),
            max_gap = balusters_max_gap(b),
            max_tilt_offset = balusters_max_tilt_offset(b),
            vspan = balusters_vspan(b),
            maps = balusters_maps(b),
            intersections = [for (avg=avgaps) if (len(avg)>1) for (t=tuples(2,avg)) if (t[1][1][0]==t[0][1][1]&&t[1][1][1]==t[0][1][0]) let(a=t[0][0][len(t[0][0])-1],b=t[1][0][0]) [((a[1]+a[0])/2+(b[1]+b[0])/2)/2, (a[2]+b[2])/2]],
            intersection_height_histogram = [for (g=vgroupby(1,vquicksort(1,intersections))) [g[0][1], len(g)]],
            rod_tilt_histogram = [for (g=vgroupby(0,vquicksort(0,[for (r=rods) [r[1]-r[0], r]]))) [g[0][0], len(g)]],
            intersection_hgaps = [for (t=tuples(2,concat([0],[for (i=intersections) i[0]],[hspan]))) t[1]-t[0]],
            intersection_vgaps = [for (t=tuples(2,intersections)) t[1][1]-t[0][1]],
            intersection_vgap_deltas = [for (vgp=tuples(2,intersection_vgaps)) vgp[1]-vgp[0]],
            intersection_valign_count = v_sum([for (ivg=intersection_vgaps) if(abs(ivg)<=2*vres) 1]),
            intersection_vtrend_count = v_sum([for (ivgd=intersection_vgap_deltas) if(abs(ivgd)<=2*vres) 1]),
            terms=[
//                    "consistent_gap_area", v_std([for (g=gaps) g[0]/(vspan*max_gap)]),
                    "avoid_parallel_runs", v_avg([for (g=gaps) v_sum([for (t=tuples(2,g[1])) max(0,(hres*vres/vspan)-abs((t[1][1]-t[1][0])-(t[0][1]-t[0][0])))])]),
                    "intersections_per_gap", 2*v_std([for (avg=avgaps) len(avg)],2.5),
                    "intersection_height_histogram", debug ? intersection_height_histogram : 0,
                    "rod_tilt_histogram", debug ? rod_tilt_histogram : 0,
                    "rod_tilt_diversity", let(offsets=2*max_tilt_offset) (offsets-len(rod_tilt_histogram))*len(rods)/offsets+v_std([for (b=rod_tilt_histogram) b[1]]),
                    "avoid_bias", abs(bias),
                    "std_intersection_hgaps", v_std(intersection_hgaps)/max_gap,
                    "intersection_valign_count", intersection_valign_count,
                    "intersection_vtrend_count", intersection_vtrend_count,
                    "dummy", 0])
        debug ? [for (i=[0:len(terms)-3]) terms[i]] : v_sum([for (i=[1:2:len(terms)-3]) terms[i]]) - 3;

function countzeros(v, threshold=0, i=0, count=0, maxcount=0) =
        i >= len(v) ? maxcount
        : countzeros(v, threshold, i+1, abs(v[i])<=threshold?count+1:0, max(count, maxcount));

function randomize(v, seed) =
        len(v) == 0 ? []
        : (let(rv=rv(len(v),seed))
           [for (p=vquicksort(0, [for (i=[0:len(v)-1]) [rv[i], v[i]]])) p[1]]);

function balusters_fill(b) =
        let(rods=balusters_rods(b),
            bottom_map=balusters_bottom_map(b))
        len(rods) == len(bottom_map) ? b
        : balusters_fill(balusters_add(b, rv[n], [len(rods), len(rods)]));

function balusters_bias_fill(dir, b, last=[0,0], seed=undef) =
        let(maps=balusters_maps(b),
            hres=balusters_hres(b),
            max_spacing=balusters_max_spacing(b),
            max_tilt_offset=balusters_max_tilt_offset(b),
            min_offset=let(o=min(1,floor(max_spacing/hres)-1)) last[0]==0&&dir>0?o:2*o,
            max_offset=let(o=max(max_tilt_offset,ceil(max_spacing/hres)-1)) last[0]==0&&dir>0?o:2*o,
            rv = rv(2,seed==undef?balusters_seed(b):seed),
            n=len(maps[0]),
            candidates=[for (bo=[min_offset:max_offset]) for (to=[min_offset:max_offset]) let(b=last[0]+bo,t=last[1]+to) if (to != bo && sign(dir)*(t-b) > 0 && abs(t-b) <= max_tilt_offset && t < n && b < n) [b, t]],
            valid_candidates=[for (c=candidates) if (balusters_check_rod(b, c)) c],
            next=choice(rv[0], valid_candidates))
        next == undef || max(next[0],next[1]) >= n ? b
        : balusters_bias_fill(
                dir,
                balusters_add(b, rv[n], next),
                last=next,
                seed=rv[1]);

function balusters_swap(b, n, seed=undef) =
        let(rv=rv(3,seed==undef?balusters_seed(b):seed))
        n <= 0 ? b
        : balusters_swap(
                let(rods=balusters_rods(b),
                    top_map=balusters_top_map(b),
                    vspan=balusters_vspan(b),
                    hres=balusters_hres(b),
                    rod_a_i=floor(rv[0]*len(rods)),
                    rod_a=rods[rod_a_i],
                    max_tilt_offset = balusters_max_tilt_offset(b),
                    rod_bs=[for (rod_b_top=[for (i=[-max_tilt_offset:max_tilt_offset]) rod_a[1]+i]) if (rod_b_top>=0 && rod_b_top<len(top_map)) rods[top_map[rod_b_top]]],
                    valid_rod_bs=[for (rod_b=rod_bs) if (abs(rod_a[1]-rod_b[0])<=max_tilt_offset&&abs(rod_b[1]-rod_a[0])<=max_tilt_offset) rod_b])
                len(valid_rod_bs) == 0 ? b
                : (let(rod_b=choice(rv[1], valid_rod_bs))
                   [ balusters_hspan(b),
                     balusters_vspan(b),
                     balusters_hres(b),
                     balusters_vres(b),
                     balusters_max_tilt_offset(b),
                     balusters_seed(b),
                     balusters_max_gap(b),
                     v_set(v_set(rods,rod_a[0],[rod_a[0],rod_b[1]]),rod_b[0],[rod_b[0],rod_a[1]]),
                     balusters_bottom_map(b),
                     v_set(v_set(top_map,rod_a[1],rod_b[0]),rod_b[1],rod_a[0])]),
                n-1,
                rv[2]);

module instructions(b) {
    hspan=balusters_hspan(b);
    vspan=balusters_vspan(b);
    hres=balusters_hres(b);
    margin=balusters_margin(b);

    color("black") {
        projection(cut=true) {
            difference() {
                // bottom rail
                translate([0,-bottom_rail_width()/2,-inches(1)]) {
                    cube([hspan,bottom_rail_width(),inches(2)]);
                }
                balusters(b);
            }
        }
    }
    color("black") {
        projection(cut=true) {
            translate([0,bottom_rail_width()/2+hres*4+vspan/2,0]) {
                translate([0,0,-baluster_diameter()/2]) {
                    rotate([-90,0,0]) {
                        translate([0,0,-vspan/2]) {
                            balusters(b,socket_depth=0,cubes=true);
                        }
                    }
                }
                translate([0,0,baluster_diameter()/2]) {
                    rotate([-90,0,0]) {
                        translate([0,0,-vspan/2]) {
                            balusters(b,socket_depth=0,cubes=true);
                        }
                    }
                }
            }
        }
    }
    color("black") {
        projection(cut=true) {
            translate([0,bottom_rail_width()/2+hres*10+vspan,0]) {
                rotate([180,0,0]) {
                    difference() {
                        // top rail
                        translate([0,-top_rail_width()/2,-inches(1)]) {
                            cube([hspan,top_rail_width(),inches(2)]);
                        }
                        translate([0,0,-vspan]) {
                            balusters(b);
                        }
                    }
                }
            }
        }
    }

    font_size=hres*0.7;
    rods=balusters_rods(b);
    color("black") {
        socket_depth=baluster_socket_depth();
        for (o=[1:balusters_max_tilt_offset(b)]) {
            translate([-2*hres-hres*(balusters_max_tilt_offset(b)-o),bottom_rail_width()/2+4*hres+vspan/2,0]) {
                rotate([0,0,90]) {
                    rod_length=let(x=hres*o,y=vspan+2*socket_depth) norm([x,y]);
                    rod_count=len([for (r=rods) if (abs(r[1]-r[0])==o) r]);
                    text(str(rod_count, " rod(s) of length ", fmt_frac(rod_length), "\" for tilt offset ", o, " (", round(balusters_tilt(b, o)), "°)"),size=font_size,font="Times Roman",halign="center",valign="center");
                }
            }
        }
        translate([margin,0,0]) {
            maps=balusters_maps(b);
            for (i=[0,1]) {
                translate([0,bottom_rail_width()/2+hres*2+i*(hres*5+vspan),0]) {

                    translate([hres*-2,0,0]) {
                        rotate([0,0,90]) {
                            translate([0,1*hres,0]) text("Tilt",size=font_size,font="Times Roman",halign="right",valign="center");
                            text("Offset",size=font_size,font="Times Roman",halign="right",valign="center");
                            translate([(i*2-1)*(bottom_rail_width()+hres*3)+i*hres,0,0]) {
                                text("Slot",size=font_size,font="Times Roman",halign="right",valign="center");
                            }
                            translate([(i*2-1)*(bottom_rail_width()+hres*8)+i*hres*1,0,0]) {
                                translate([0,2*hres,0]) text("From",size=font_size,font="Times Roman",halign="right",valign="center");
                                translate([0,1*hres,0]) text("First",size=font_size,font="Times Roman",halign="right",valign="center");
                                text("Slot",size=font_size,font="Times Roman",halign="right",valign="center");
                            }
                            translate([(i*2-1)*(bottom_rail_width()+hres*13)+i*hres*1,0,0]) {
                                translate([0,1*hres,0]) text("From",size=font_size,font="Times Roman",halign="right",valign="center");
                                text("End",size=font_size,font="Times Roman",halign="right",valign="center");
                            }
                        }
                    }

                    m=maps[i];
                    for (j=[0:len(m)-1]) {
                        k = m[j];
                        o = k==undef ? "- " : let(r=rods[k]) str(r[abs(i-1)]-r[i]);
                        translate([hres*j,0,0]) {
                            rotate([0,0,90]) {
                                text(o,size=font_size,font="Times Roman",halign="right",valign="center");
                                translate([(i*2-1)*(bottom_rail_width()+hres*3)+i*hres,0,0]) {
                                    text(str(j+1),size=font_size,font="Times Roman",halign="right",valign="center");
                                }
                                translate([(i*2-1)*(bottom_rail_width()+hres*8)+i*hres*1,0,0]) {
                                    text(fmt_frac(hres*j),size=font_size,font="Times Roman",halign="right",valign="center");
                                }
                                translate([(i*2-1)*(bottom_rail_width()+hres*13)+i*hres*1,0,0]) {
                                    text(fmt_frac(margin+hres*j),size=font_size,font="Times Roman",halign="right",valign="center");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

function fmt_frac(x,res=16) = let(u=floor(x),f=round((x-u)*res)) f==0 ? str(u) : let(s=simplify_frac(f,res)) str(u!=0?str(u," "):"",s[0],"/",s[1]);
function simplify_frac(n,d) = let(gcd=gcd(n,d)) [n/gcd,d/gcd];

function gcd(a,b)=
 a<=0||b<=0?min(sign(a),sign(b)):
   a % b==0?b:
   gcd(b,a % b);

// given to shawn:
//railing = balusters_load([92.75, 31.5, 0.75, 0.75, 3, 3.375, 258974, 0.2842, [[4, 7], [5, 3], [8, 6], [10, 12], [13, 10], [15, 14], [17, 19], [19, 17], [20, 23], [23, 21], [25, 26], [28, 25], [31, 30], [32, 34], [35, 32], [37, 36], [39, 42], [41, 38], [43, 44], [46, 49], [48, 47], [50, 53], [53, 50], [55, 54], [56, 57], [60, 63], [61, 58], [63, 61], [65, 66], [68, 71], [71, 68], [74, 73], [77, 78], [80, 83], [83, 80], [84, 85], [87, 86], [89, 91], [92, 94], [93, 90], [96, 99], [98, 95], [100, 103], [101, 100], [105, 106], [109, 107], [111, 112], [115, 117], [118, 115], [119, 122], [121, 119]]]);


ib = balusters_new(inches(92+3/4),vertical_span(),initial_seed=707044);
//ib = balusters_new(inches(60), vertical_span());

railing = fill_gaps(ib);

//railing = balusters_load([92.75, 31.5, 1, 1, 3, 3.375, 230203, 0.110842, [[2, 5], [3, 2], [5, 7], [7, 10], [10, 8], [11, 12], [14, 15], [17, 16], [19, 17], [22, 25], [23, 20], [25, 22], [27, 28], [29, 31], [31, 29], [32, 34], [34, 37], [36, 33], [37, 40], [39, 42], [42, 41], [44, 45], [46, 48], [49, 46], [50, 49], [52, 53], [56, 54], [59, 57], [60, 61], [62, 59], [65, 63], [66, 67], [70, 69], [73, 72], [75, 74], [78, 80], [79, 76], [81, 82], [83, 85], [87, 84], [88, 91], [89, 87], [91, 89]]]);

//railing = balusters_load([92.75, 31.5, 0.75, 0.75, 3, 3.375, 779202, 0.413157, [[5, 2], [6, 5], [7, 8], [11, 12], [14, 16], [19, 20], [22, 23], [25, 22], [26, 28], [30, 32], [35, 37], [36, 34], [39, 40], [44, 42], [48, 47], [52, 50], [56, 53], [57, 60], [59, 56], [62, 63], [65, 64], [68, 65], [71, 69], [74, 76], [75, 72], [77, 80], [80, 83], [83, 86], [86, 84], [88, 90], [90, 87], [92, 94], [96, 99], [100, 103], [105, 106], [110, 108], [115, 112], [116, 118], [117, 115], [121, 120]]]);


// it finished at 3/4"!!!
//railing = balusters_load([92.75, 31.5, 0.75, 0.75, 3, 3.375, 707044, 0.0365556, [[1, 4], [6, 5], [8, 9], [11, 14], [12, 11], [16, 15], [19, 20], [22, 23], [25, 28], [29, 26], [30, 32], [32, 29], [34, 33], [37, 35], [38, 41], [39, 38], [42, 43], [45, 46], [48, 45], [52, 49], [53, 56], [55, 53], [57, 58], [60, 57], [62, 60], [65, 64], [68, 70], [69, 67], [72, 73], [75, 77], [79, 76], [81, 79], [83, 82], [85, 87], [86, 84], [90, 92], [94, 93], [97, 100], [98, 95], [102, 103], [106, 108], [109, 111], [110, 107], [112, 114], [113, 110], [115, 118], [119, 117], [120, 123], [122, 120]]]);

// it finished at 1"!!!
//railing = balusters_load([92.75, 31.5, 1, 1, 3, 3.375, 707044, 0.332262, [[2, 1], [4, 7], [6, 4], [8, 10], [10, 13], [13, 12], [16, 14], [17, 19], [19, 16], [21, 20], [23, 24], [24, 21], [26, 28], [29, 30], [30, 27], [32, 33], [33, 36], [36, 39], [40, 38], [42, 40], [43, 45], [44, 42], [46, 47], [48, 51], [52, 49], [53, 55], [54, 52], [56, 59], [59, 58], [60, 62], [64, 63], [67, 68], [68, 65], [70, 69], [72, 73], [74, 71], [75, 78], [77, 74], [80, 79], [82, 83], [86, 85], [87, 89], [90, 87], [92, 90]]]);

echo(str("railing = balusters_load(",balusters_dump(railing),");"));

balusters_report(railing);

rotate([0,0,-90]) {
//    instructions(railing);

    translate([0, -feet(2), inches(12)]) {
        railing(railing);
    }
}

