use <math.scad>;

$fn = 12;

function feet(ft,in=0) = inches(ft*12+in);
function inches(in) = in;

function max_tilt_offset() = 3;
function horizontal_resolution() = inches(3/4);
function vertical_resolution() = inches(3/4);
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

function scale2int(x, min_int, max_int) = min_int+floor(x*(max_int-min_int));
function choice(x, v) = v[scale2int(x,0,len(v))];
function weighted_choice(x, v) = weighted_choice_recur(x, vquicksort(0, v), v_sum([for (i=v) i[0]]), len(v)-1);
function weighted_choice_recur(x, v, total, i) = let(w=v[i][0]/total) x<=w ? v[i][1] : weighted_choice_recur(x-w, v, total, i-1);
function v_set(v,i,x) = [for (j=[0:len(v)-1]) j==i?x:v[j]];

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

// balusters: [hspan, vspan, hres, vres, rods, bottom_map, top_map]

function balusters_hspan(b) = b[0];
function balusters_vspan(b) = b[1];
function balusters_hres(b) = b[2];
function balusters_vres(b) = b[3];
function balusters_max_tilt_offset(b) = b[4];
function balusters_seed(b) = b[5];
function balusters_max_gap(b) = b[6];
function balusters_rods(b) = b[7];
function balusters_bottom_map(b) = b[8];
function balusters_top_map(b) = b[9];

function balusters_maps(b) = [balusters_bottom_map(b), balusters_top_map(b)];
function balusters_max_tilt(b) = balusters_tilt(b, balusters_max_tilt_offset(b));
function balusters_tilt(b, o) = atan(o*balusters_hres(b)/balusters_vspan(b));
function balusters_max_spacing(b) = balusters_max_gap(b)+baluster_diameter();

function balusters_new(hspan, vspan, hres=horizontal_resolution(), vres=vertical_resolution(), max_tilt_offset=max_tilt_offset(), seed=undef, max_gap=max_gap()) =
        let(empty_map = [for (i=[0:floor(hspan/hres)-1]) undef])
        [hspan, vspan, hres, vspan/floor(vspan/vres), max_tilt_offset, seed==undef?floor(rands(0,1000000,1)[0]):seed, max_gap, [], empty_map, empty_map];

function balusters_dump(b) = [
        balusters_hspan(b),
        balusters_vspan(b),
        balusters_hres(b),
        balusters_vres(b),
        balusters_max_tilt_offset(b),
        balusters_seed(b),
        balusters_max_gap(b),
        [for (r=vquicksort(0,balusters_rods(b))) [r[0]+1, r[1]+1]]];

function balusters_load(b) = balusters_load_recur(
        balusters_new(
                hspan=balusters_hspan(b),
                vspan=balusters_vspan(b),
                hres=balusters_hres(b),
                vres=balusters_vres(b),
                max_tilt_offset=balusters_max_tilt_offset(b),
                seed=balusters_seed(b),
                max_gap=balusters_max_gap(b)),
        balusters_rods(b));
function balusters_load_recur(b, rods, i=0) = i>=len(rods) ? b : balusters_load_recur(balusters_add(b, [for (s=rods[i]) s-1]), rods, i+1);

function balusters_margin(b) =
        let(hspan = balusters_hspan(b),
            hres = balusters_hres(b),
            slots = len(balusters_bottom_map(b)))
        (hspan-hres*(slots-1))/2;

function balusters_check(b, rod) =
        let(maps=balusters_maps(b),
            tests=[for (i=[0,1]) let(r=rod[i],m=maps[i]) r > 0 && r < len(m) && m[r] == undef/* && balusters_check2(b, i, sign(rod[abs(i-1)]-r), r, m]*/])
        tests[0] && tests[1];

/*
function balusters_check2(b, i, s, r, m) =
        let(rods=balusters_rods(b),
            [for (o=[1:s*balusters_max_tilt_offset(b)]) let(j=m[o]) if(j!=undef) let(r2=rods[j],o2=r2[abs(i-1)]-r2[i]) if(sign(s2)==s&&o2)
*/

function v_sum(v, start=0, end=undef, sum=0) =
        start >= len(v) || (end != undef && start >= end)
        ? sum
        : v_sum(v, start + 1, end, sum+(start<0||start>=len(v)?0:v[start]));

function balusters_add(b, rod) =
        let(rods=balusters_rods(b))
        concat([balusters_hspan(b),
                balusters_vspan(b),
                balusters_hres(b),
                balusters_vres(b),
                balusters_max_tilt_offset(b),
                balusters_seed(b),
                balusters_max_gap(b),
                concat(rods,[rod])],
               let(maps=balusters_maps(b),
                   l=len(rods))
               [for (i=[0,1]) v_set(maps[i],rod[i],len(rods))]);

// Set of crossings at each level dictated by vres
function balusters_crossings(b, i=0, result=[]) =
        let(n=round(balusters_vspan(b)/balusters_vres(b)))
        i > n ? result
        : balusters_crossings(b, i+1, concat(result,
          [let(margin=balusters_margin(b),
               hres=balusters_hres(b),
               slope=hres*i/n)
           quicksort([for (r=balusters_rods(b)) margin + hres*r[0] + slope*(r[1]-r[0])])]));

// Gaps in a set of balusters, as a vector of [width, hoffset, voffset], ordered by increasing width
function balusters_gaps(b, diameter=baluster_diameter(), i=0, result=[]) =
        vquicksort(0, [for (hg=balusters_hgaps(b, diameter=diameter)) for (g=hg) g]);

// Gaps in a set of balusters, as a vector of horizontal rows of [width, hoffset, voffset]
function balusters_hgaps(b, diameter=baluster_diameter()) =
        let(c=balusters_crossings(b),
            vres=balusters_vres(b))
        [for (i=[0:len(c)-1])
                [for (t=tuples(2,concat([-diameter/2], c[i], [balusters_hspan(b)+diameter/2])))
                        let (a=t[0],b=t[1])
                                [max(0,b-a-diameter), (a+b)/2, i*vres]]];

function tuples(k, v, i=0, result=[]) =
        (i + k) > len(v)
        ? result
        : tuples(k, v, i+1, concat(result, [[for (j=[i:i+k-1]) v[j]]]));

function balusters_largest_gaps(b, diameter=baluster_diameter()) =
        let(gv=balusters_gaps(b, diameter=diameter),
            maxg=gv[len(gv)-1][0])
        [for (g=gv) if (g[0]==maxg) g];

function fill_gaps(b, seed=undef, depth=0) =
        let(gaps = balusters_largest_gaps(b),
            rv = rv(4,seed==undef?balusters_seed(b):seed),
            vspan = balusters_vspan(b),
            hres = balusters_hres(b),
            vres = balusters_vres(b),
            gap = choice(rv[0], gaps),
            max_gap = balusters_max_gap(b),
            gap_x = gap[1],
            gap_y = gap[2],
            hspan = balusters_hspan(b),
            margin = balusters_margin(b),
            max_tilt_offset = balusters_max_tilt_offset(b),
            tilts = [for (i=[-max_tilt_offset:max_tilt_offset]) if (i!=0) let(x=gap_x-i*hres*gap_y/vspan) [x,x+i*hres]],
            snaps = concat([for (t=tilts) [for (c=t) floor(c/hres)]], [for (t=tilts) [for (c=t) ceil(c/hres)]]),
            candidates = [for (s=snaps) if(balusters_check(b, s)) s],
//            weighted_candidates = [for (c=candidates) [let(t=abs(c[1]-c[0])) t==0?1:(1+max_tilt_offset-t)*100, c]],
            weighted_candidates = [for (c=candidates) [1, c]],
            weighted_b2s = [for (wc=weighted_candidates) let(b2=balusters_add(b, wc[1])) if (balusters_bias_check(b2)) [wc[0], b2]])
        len(weighted_b2s) == 0 || gaps[0][0] <= max_gap
        ? b
        : fill_gaps(vquicksort(0, [for (b2=weighted_randomize(weighted_b2s,rv[2])) [balusters_score(b2), b2]])[0][1], rv[3], depth=depth+1);

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
    echo(seed=balusters_seed(b));
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
    for (g=[for (i=[max(0,len(gaps)-5):len(gaps)-1]) gaps[i]]) {
        echo(g=g);
        if (g[0]>max_gap) {
            translate([g[1],0,bottom_rail_height()+g[2]]) {
                color(g[0]>max_gap?"red":"black",0.3) sphere(r=inches(2),$fn=30);
            }
        }
    }
}

module balusters(b,socket_depth=baluster_socket_depth(),cubes=false) {
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

    gaps = balusters_gaps(b);
    for (g=[for (i=[max(0,len(gaps)-5):len(gaps)-1]) gaps[i]]) {
        echo(g=g);
        if (g[0]>max_gap) {
            translate([g[1],0,bottom_rail_height()+g[2]]) {
                color(g[0]>max_gap?"red":"black",0.3) sphere(r=inches(2),$fn=30);
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
        balusters(b);
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

function balusters_bias_check(b) =
        let(tests=[for (bias=[-1,1]) balusters_bias_check_recur(b, vquicksort(0, [for (r=balusters_rods(b)) if (sign(r[1]-r[0])==sign(bias)) r]))])
        tests[0] && tests[1];

function balusters_bias_check_recur(b, rods, i=1) =
        i >= len(rods) || rods[i-1][1] >= rods[i][0] ? i >= len(rods)
        : balusters_bias_check_recur(b, rods, i+1);

function balusters_score(b,debug=false) =
        let(hgaps = balusters_hgaps(b, diameter=0),
            vgaps = [for (i=[0:len(hgaps[0])-1]) [for (hg=hgaps) hg[i]]],
            vres = balusters_vres(b),
            rods = balusters_rods(b),
            bias = v_sum([for (r=rods) r[1]-r[0]])/len(rods),
            hspan = balusters_hspan(b),
            maps = balusters_maps(b),
            max_gap = balusters_max_gap(b),
            ideal_hgap = hspan/len(vgaps),
            vruns = [for (vg=vgaps) [for (i=[1:len(vg)-1]) vg[i]-vg[i-1]]],
            parallel_runs = [for (vr=vruns) countzeros([for (g=vr) g[0]])],
            intersections = [for (vg=vgaps) let(svg=vquicksort(0,vg),g=svg[0]) if (g[0]<baluster_diameter()) g],
            intersection_hgaps = [for (it=tuples(2,concat([[undef,0,undef]],intersections,[[undef,hspan,undef]]))) it[1][1]-it[0][1]],
            intersection_vgaps = [for (it=tuples(2,intersections)) it[1][2]-it[0][2]],
            intersection_gaps = [for (it=tuples(2,intersections)) norm([it[1][1]-it[0][1], it[1][2]-it[0][2]])],
            multi_intersection_count = v_sum([for (ig=intersection_gaps) if(ig<=norm([baluster_diameter(),2*vres])) 1]),
            intersection_vgap_deltas = [for (vgp=tuples(2,intersection_vgaps)) vgp[1]-vgp[0]],
            intersection_valign_count = v_sum([for (ivg=intersection_vgaps) if(abs(ivg)<=2*vres) 1]),
            intersection_vtrend_count = v_sum([for (ivgd=intersection_vgap_deltas) if(abs(ivgd)<=2*vres) 1]),
            terms=[
                    "parallel_runs", let(x=v_sum([for (pr=parallel_runs) pr/len(vgaps)])) debug ? [x, len(vgaps), parallel_runs] : x,
                    "bias", abs(bias),
                    "consistent_hgaps", let(v=[for (hg=[hgaps[0],hgaps[len(hgaps)-1]]) for (g=hg) g[0]],s=v_std(v),a=v_avg(v),x=s/a) debug ? [x, s, a] : x,
                    "intersection_density", (hspan/(max_gap+baluster_diameter())-1)*abs(intersection_density()-len(intersections)/len(rods)),
                    "multi_interection_count", multi_intersection_count,
                    "intersection_valign_count", intersection_valign_count,
                    "intersection_vtrend_count", intersection_vtrend_count,
                    "triple_slot_fill_count", v_sum([for (m=maps) for (t=tuples(3,[for (s=m) s==undef?0:1])) if (v_sum(t)==3) 1]),
                    "consistent_intersection_gaps", let(x=2*v_std(intersection_hgaps)/v_avg(intersection_hgaps)) debug ? [x, intersection_hgaps, v_std(intersection_hgaps), v_avg(intersection_hgaps)] : x,
                    "dummy", 0])
        debug ? [for (i=[0:len(terms)-3]) terms[i]] : v_sum([for (i=[1:2:len(terms)-3]) terms[i]]);

function v_std(v,avg=undef) = len(v) <= 1 ? 0 : let(a=avg!=undef?avg:v_avg(v)) sqrt(v_sum([for (x=v) let(d=x-a) d*d])/(len(v)-1));
function v_avg(v) = len(v) == 0 ? 0 : v_sum(v)/len(v);

function countzeros(v, threshold=0, i=0, count=0, maxcount=0) =
        i >= len(v) ? maxcount
        : countzeros(v, threshold, i+1, abs(v[i])<=threshold?count+1:0, max(count, maxcount));

function randomize(v, seed) =
        let(rv=rv(len(v),seed))
        [for (p=vquicksort(0, [for (i=[0:len(v)-1]) [rv[i], v[i]]])) p[1]];

function weighted_randomize(v, seed) =
        let(rv=rv(len(v),seed))
        [for (p=vquicksort(0, [for (i=[0:len(v)-1]) [let(w=v[i][0]) rv[i]*w*w, v[i][1]]])) p[1]];

function balusters_fill(b) =
        let(rods=balusters_rods(b),
            bottom_map=balusters_bottom_map(b))
        len(rods) == len(bottom_map) ? b
        : balusters_fill(balusters_add(b, [len(rods), len(rods)]));

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
            valid_candidates=[for (c=candidates) if (balusters_check(b, c)) c],
            next=choice(rv[0], valid_candidates))
        next == undef || max(next[0],next[1]) >= n ? b
        : balusters_bias_fill(
                dir,
                balusters_add(b, next),
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
    color("black") {
        socket_depth=baluster_socket_depth();
        for (o=[1:balusters_max_tilt_offset(b)]) {
            translate([-2*hres-hres*(balusters_max_tilt_offset(b)-o),bottom_rail_width()/2+(hres*5+vspan)/2,0]) {
                rotate([0,0,90]) {
                    rod_length=let(x=hres*o,y=vspan+2*socket_depth) norm([x,y]);
                    text(str("rod length for tilt offset ", o, " (", round(balusters_tilt(b, o)), "°):"),size=font_size,font="Times Roman",halign="right",valign="center");
                    translate([hres,0,0]) {
                        text(fmt_frac(rod_length),size=font_size,font="Times Roman",halign="left",valign="center");
                    }
                }
            }
        }
        translate([margin,0,0]) {
            maps=balusters_maps(b);
            rods=balusters_rods(b);
            for (i=[0,1]) {
                translate([0,bottom_rail_width()/2+hres*2+i*(hres*5+vspan),0]) {

                    translate([hres*-2,0,0]) {
                        rotate([0,0,90]) {
                            translate([0,1*hres,0]) text("Tilt",size=font_size,font="Times Roman",halign="right",valign="center");
                            text("Offset",size=font_size,font="Times Roman",halign="right",valign="center");
                            translate([(i*2-1)*(bottom_rail_width()+hres*3)+i*hres,0,0]) {
                                text("Slot",size=font_size,font="Times Roman",halign="right",valign="center");
                            }
                            translate([(i*2-1)*(bottom_rail_width()+hres*6)+i*hres*2,0,0]) {
                                translate([0,2*hres,0]) text("From",size=font_size,font="Times Roman",halign="right",valign="center");
                                translate([0,1*hres,0]) text("First",size=font_size,font="Times Roman",halign="right",valign="center");
                                text("Slot",size=font_size,font="Times Roman",halign="right",valign="center");
                            }
                            translate([(i*2-1)*(bottom_rail_width()+hres*11)+i*hres*2,0,0]) {
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
                                translate([(i*2-1)*(bottom_rail_width()+hres*6)+i*hres*2,0,0]) {
                                    text(fmt_frac(hres*j),size=font_size,font="Times Roman",halign="right",valign="center");
                                }
                                translate([(i*2-1)*(bottom_rail_width()+hres*11)+i*hres*2,0,0]) {
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

//translate([0,0,feet(4)])
//railing(balusters_swap(balusters_fill(balusters_new(inches(100),vertical_span())),n=1000));

//railing = fill_gaps(balusters_bias_fill(1, balusters_bias_fill(-1, balusters_new(inches(100),vertical_span()))));

// given to shawn: railing = balusters_load([92.75, 31.5, 0.75, 0.75, 3, 258974, 3.375, [[4, 7], [5, 3], [8, 6], [10, 12], [13, 10], [15, 14], [17, 19], [19, 17], [20, 23], [23, 21], [25, 26], [28, 25], [31, 30], [32, 34], [35, 32], [37, 36], [39, 42], [41, 38], [43, 44], [46, 49], [48, 47], [50, 53], [53, 50], [55, 54], [56, 57], [60, 63], [61, 58], [63, 61], [65, 66], [68, 71], [71, 68], [74, 73], [77, 78], [80, 83], [83, 80], [84, 85], [87, 86], [89, 91], [92, 94], [93, 90], [96, 99], [98, 95], [100, 103], [101, 100], [105, 106], [109, 107], [111, 112], [115, 117], [118, 115], [119, 122], [121, 119]]]);

// intentonally broken railing = balusters_load([92.75, 31.5, 0.75, 0.75, 3, 258974, 3.375, [[4, 6], [7, 3], [5, 5], [10, 12], [13, 10], [15, 14], [17, 19], [19, 17], [20, 23], [23, 21], [25, 26], [28, 25], [31, 30], [32, 34], [35, 32], [37, 36], [39, 42], [41, 38], [43, 44], [46, 49], [48, 47], [50, 53], [53, 50], [55, 54], [56, 57], [60, 63], [61, 58], [63, 61], [65, 66], [68, 71], [71, 68], [74, 73], [77, 78], [80, 83], [83, 80], [84, 85], [87, 86], [89, 91], [92, 94], [93, 90], [96, 99], [98, 95], [100, 103], [101, 100], [105, 106], [109, 107], [111, 112], [115, 117], [118, 115], [119, 122], [121, 119]]]);


railing = fill_gaps(balusters_new(inches(92+3/4),vertical_span()));
//railing = fill_gaps(balusters_new(inches(30),vertical_span()));

echo(str("railing = balusters_load(",balusters_dump(railing),");"));

balusters_report(railing);

rotate([0,0,-90]) {
//    instructions(railing);
}

railing(railing);
