use <math.scad>;

$fn = 10;

// TODO: score by slants
// TODO: eliminate intersections of >2 rods

function feet(ft,in=0,frac=0) = inches(ft*12 + in + frac);
function inches(in,frac=0) = in + frac;

function max_tilt_offset() = 4;
function horizontal_resolution() = inches(3/4);
function vertical_resolution() = inches(3/4);
function max_gap() = inches(3.375);
function railing_height() = inches(38);
function railing_bottom_gap() = inches(3);
function vertical_span() = railing_height()-railing_bottom_gap()-top_rail_height()-bottom_rail_height();

function post_width() = inches(8);
function post_height() = inches(42);
function top_rail_height() = inches(1.5);
function top_rail_width() = inches(3);
function bottom_rail_height() = inches(1.5);
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
function balusters_max_tilt(b) = atan(balusters_max_tilt_offset(b)*balusters_hres(b)/balusters_vspan(b));
function balusters_max_spacing(b) = balusters_max_gap(b)+baluster_diameter();

function balusters_new(hspan, vspan, hres=horizontal_resolution(), vres=vertical_resolution(), max_tilt_offset=max_tilt_offset(), seed=undef, max_gap=max_gap()) =
        let(empty_map = [for (i=[0:floor(hspan/hres)-1]) undef])
        [hspan, vspan, hres, vspan/floor(vspan/vres), max_tilt_offset, seed==undef?floor(rands(0,1000000,1)[0]):seed, max_gap, [], empty_map, empty_map];

function balusters_margin(b) =
        let(hspan = balusters_hspan(b),
            hres = balusters_hres(b))
        (hspan-hres*floor(hspan/hres))/2;

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

// Gaps in a set of crossings, as a vector of [width, hoffset, vindex]
function balusters_gaps(b, cv, i=0, result=[]) =
        i>=(len(cv)-1)
        ? result
        : balusters_gaps(b, cv, i+1, concat(result, [for (hg=balusters_hgaps(b, cv[i])) concat(hg, [i])]));

// Gaps along a single horizontal as a vector of [width, hoffset]
function balusters_hgaps(b, c) = balusters_hgaps_recurse(b, concat([0], c, [balusters_hspan(b)]));
function balusters_hgaps_recurse(b, c, i=0, result=[]) =
        i>=(len(c)-1)
        ? result
        : balusters_hgaps_recurse(b, c, i+1, concat(result, [let (a=c[i],b=c[i+1]) [max(0,b-a-baluster_diameter()), (a+b)/2]]));

function balusters_largest_gaps(b) =
        let(gv=vquicksort(0, balusters_gaps(b, balusters_crossings(b))),
            maxg=gv[len(gv)-1][0])
        [for (g=gv) if (g[0]==maxg) g];

function fill_gaps(b, seed=undef, depth=0) =
        let(gaps = balusters_largest_gaps(b),
            rv = rv(3,seed==undef?balusters_seed(b):seed),
            vspan = balusters_vspan(b),
            hres = balusters_hres(b),
            vres = balusters_vres(b),
            gap = choice(rv[0], gaps),
            hspan = balusters_hspan(b),
            margin = balusters_margin(b),
            max_tilt_offset = balusters_max_tilt_offset(b),
            tilts = [for (i=[-max_tilt_offset:max_tilt_offset]) if (i!=0) let(x=gap[1]-i*hres*vres*gap[2]/vspan) [x,x+i*hres]],
            snaps = concat([for (t=tilts) [for (c=t) floor(c/hres)]], [for (t=tilts) [for (c=t) ceil(c/hres)]]),
            candidates = [for (s=snaps) if(balusters_check(b, s)) s],
            weighted_candidates = [for (c=candidates) [let(t=abs(c[1]-c[0])) t==0?1:1+max_tilt_offset-t, c]],
            weighted_b2s = [for (wc=weighted_candidates) let(b2=balusters_add(b, wc[1])) if (balusters_bias_check(b2)) [wc[0], b2]])
        len(weighted_b2s) == 0 || gaps[0][0] < balusters_max_gap(b)
        ? b
        : fill_gaps(vquicksort(0, [for (b2=weighted_randomize(weighted_b2s,rv[1])) [balusters_score(b2), b2]])[0][1], rv[2], depth=depth+1);

module railing(b) {
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
    echo(max_tilt_offset=max_tilt_offset());
    echo(seed=balusters_seed(b));
    echo(max_gap=max_gap);

    echo(max_tilt=balusters_max_tilt(b));
    echo(margin=margin);
    echo(max_spacing=max_spacing);

    echo(rods=len(rods));

    // balusters
    translate([margin, 0, bottom_rail_height()]) {
        for (r=rods) {
            translate([r[0]*hres, 0, 0]) {
                a = atan((r[1]-r[0])*hres/vspan);
                rotate([0, a, 0]) {
                    socket_depth = baluster_socket_depth()/cos(a);
                    translate([0, sign(a)*baluster_diameter()/2, -socket_depth]) {
                        color("black",0.5) {
                            cylinder(d=baluster_diameter(), h=vspan/cos(a)+2*socket_depth, center=false);
                        }
                    }
                }
            }
        }
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

    echo(score=balusters_score(b));
    echo(bias=let(rods=balusters_rods(b)) v_sum([for (r=rods) r[1]-r[0]])/len(rods));

    vres = balusters_vres(b);
    gaps = vquicksort(0, balusters_gaps(b, balusters_crossings(b)));
    for (g=[for (i=[max(0,len(gaps)-5):len(gaps)-1]) gaps[i]]) {
        echo(g=g);
        if (g[0]>max_gap) {
            translate([g[1],0,bottom_rail_height()+vres*g[2]]) {
                color(g[0]>max_gap?"red":"black",0.3) sphere(r=inches(2),$fn=30);
            }
        }
    }
}

function balusters_bias_check(b) =
        let(tests=[for (bias=[-1,1]) balusters_bias_check_recur(b, vquicksort(0, [for (r=balusters_rods(b)) if (sign(r[1]-r[0])==sign(bias)) r]))])
        tests[0] && tests[1];

function balusters_bias_check_recur(b, rods, i=1) =
        i >= len(rods) || rods[i-1][1] >= rods[i][0] ? i >= len(rods)
        : balusters_bias_check_recur(b, rods, i+1);

function balusters_score(b) =
        let(crossings = balusters_crossings(b),
            hgaps = [for (c=crossings) balusters_hgaps(b, c)],
            vgaps = [for (i=[0:len(hgaps[0])-1]) [for (hg=hgaps) hg[i][0]]],
            vruns = [for (vg=vgaps) [for (i=[1:len(vg)-1]) vg[i]-vg[i-1]]])
        (v_sum([for (vr=vruns) countzeros(vr,0.5*tan(balusters_max_tilt(b))*balusters_vres(b))/len(vr)])/len(vruns)
         + v_sum([for (hg=hgaps) max(0,countzeros([for (g=hg) g[0]],baluster_diameter())-1)]));

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

//translate([0,0,feet(4)])
//railing(balusters_swap(balusters_fill(balusters_new(inches(100),vertical_span())),n=1000));

railing_100 = fill_gaps(balusters_new(inches(100),vertical_span()));
//railing_100 = fill_gaps(balusters_bias_fill(1, balusters_bias_fill(-1, balusters_new(inches(100),vertical_span()))));

//railing_100 = [100, 32, 0.75, 0.5, 3, 3.25, [[67, 69], [37, 34], [101, 98], [19, 22], [113, 116], [53, 52], [85, 85], [14, 11], [123, 121], [29, 30], [77, 74], [40, 43], [109, 108], [63, 60], [94, 96], [8, 10], [47, 44], [124, 127], [93, 90], [78, 80], [15, 16], [7, 5], [25, 24], [58, 59], [118, 119], [72, 71], [103, 104], [129, 126], [65, 65], [38, 38], [34, 37], [89, 91], [48, 49], [116, 113], [3, 6], [98, 97], [44, 45], [82, 79], [52, 55], [128, 131], [111, 112], [12, 12], [33, 32], [107, 110], [22, 23], [30, 27], [21, 20], [102, 101], [90, 87], [4, 2], [56, 53], [81, 84], [125, 125], [73, 76], [97, 94], [60, 63], [121, 124], [70, 67], [108, 105], [20, 17], [43, 40], [57, 56], [132, 130], [51, 48], [26, 29], [86, 88]], [undef, undef, undef, 34, 49, undef, undef, 21, 15, undef, undef, undef, 41, undef, 7, 20, undef, undef, undef, 3, 59, 46, 44, undef, undef, 22, 64, undef, undef, 9, 45, undef, undef, 42, 30, undef, undef, 1, 29, undef, 11, undef, undef, 60, 36, undef, undef, 16, 32, undef, undef, 63, 38, 5, undef, undef, 50, 61, 23, undef, 55, undef, undef, 13, undef, 28, undef, 0, undef, undef, 57, undef, 25, 53, undef, undef, undef, 10, 19, undef, undef, 51, 37, undef, undef, 6, 65, undef, undef, 31, 48, undef, undef, 18, 14, undef, undef, 54, 35, undef, undef, 2, 47, 26, undef, undef, undef, 43, 58, 12, undef, 40, undef, 4, undef, undef, 33, undef, 24, undef, undef, 56, undef, 8, 17, 52, undef, undef, 39, 27, undef, undef, 62], [undef, undef, 49, undef, undef, 21, 34, undef, undef, undef, 15, 7, 41, undef, undef, undef, 20, 59, undef, undef, 46, undef, 3, 44, 22, undef, undef, 45, undef, 64, 9, undef, 42, undef, 1, undef, undef, 30, 29, undef, 60, undef, undef, 11, 16, 36, undef, undef, 63, 32, undef, undef, 5, 50, undef, 38, 61, undef, undef, 23, 13, undef, undef, 55, undef, 28, undef, 57, undef, 0, undef, 25, undef, undef, 10, undef, 53, undef, undef, 37, 19, undef, undef, undef, 51, 6, undef, 48, 65, undef, 18, 31, undef, undef, 54, undef, 14, 35, 2, undef, undef, 47, undef, undef, 26, 58, undef, undef, 12, undef, 43, undef, 40, 33, undef, undef, 4, undef, undef, 24, undef, 8, undef, undef, 56, 52, 27, 17, undef, undef, 62, 39, undef]];


/*
ECHO: max_tilt_offset = 3
ECHO: max_tilt = 6.68386
ECHO: horizontal_resolution = 1.25
ECHO: vertical_resolution = 0.5
ECHO: max_gap = 3.25
ECHO: railing_height = 38
ECHO: railing_bottom_gap = 3
ECHO: vertical_span = 32
ECHO: seed = 589350
railing_100 = [100, 32, 1.25, 0.5, [[41, 39], [20, 22], [56, 59], [68, 65], [14, 11], [30, 30], [48, 49], [71, 73], [7, 9], [62, 61], [35, 37], [17, 17], [25, 23], [55, 53], [42, 45], [76, 74], [6, 4], [70, 69], [51, 54], [10, 10], [24, 27], [36, 33], [65, 66], [3, 5], [45, 44], [59, 60], [75, 78], [11, 14], [28, 26], [32, 34], [38, 38], [60, 57], [39, 41], [21, 19], [52, 50], [16, 13], [61, 64], [49, 46], [4, 1], [79, 77], [53, 56], [74, 71], [9, 7], [23, 24], [43, 43], [33, 31], [27, 29], [18, 20], [64, 63], [46, 47], [67, 68], [13, 16], [1, 3], [50, 51], [73, 76], [77, 79], [5, 6], [37, 35], [57, 55], [40, 42], [34, 36], [26, 25], [69, 72], [22, 21]], [undef, 52, undef, 23, 38, 56, 16, 8, undef, 42, 19, 27, undef, 51, 4, undef, 35, 11, 47, undef, 1, 33, 63, 43, 20, 12, 61, 46, 28, undef, 5, undef, 29, 45, 60, 10, 21, 57, 30, 32, 59, 0, 14, 44, undef, 24, 49, undef, 6, 37, 53, 18, 34, 40, undef, 13, 2, 58, undef, 25, 31, 36, 9, undef, 48, 22, undef, 50, 3, 62, 17, 7, undef, 54, 41, 26, 15, 55, undef, 39], [undef, 38, undef, 52, 16, 23, 56, 42, undef, 8, 19, 4, undef, 35, 27, undef, 51, 11, undef, 33, 47, 63, 1, 12, 43, 61, 28, 20, undef, 46, 5, 45, undef, 21, 29, 57, 60, 10, 30, 0, undef, 32, 59, 44, 24, 14, 37, 49, undef, 6, 34, 53, undef, 13, 18, 58, 40, 31, undef, 2, 25, 9, undef, 48, 36, 3, 22, undef, 50, 17, undef, 41, 62, 7, 15, undef, 54, 39, 26, 55]]
ECHO: rods = 64
ECHO: score = 0.13101
ECHO: bias = 0.171875
ECHO: g = [3.20312, 91.875, 39]
ECHO: g = [3.20312, 65.0781, 50]
ECHO: g = [3.20312, 65.1172, 52]
ECHO: g = [3.24219, 72.3828, 13]
ECHO: g = [3.24219, 65.1172, 51]
*/

//railing_100 = [100, 32, 1.25, 0.5, 2, 3.25, [[39, 41], [59, 56], [24, 21], [12, 15], [65, 68], [49, 48], [32, 31], [72, 70], [10, 7], [18, 17], [61, 62], [44, 44], [5, 8], [54, 55], [73, 76], [26, 27], [38, 35], [6, 3], [11, 10], [77, 75], [68, 69], [48, 51], [29, 32], [21, 24], [15, 12], [35, 36], [66, 65], [60, 59], [52, 49], [2, 4], [57, 60], [69, 72], [19, 20], [42, 40], [36, 39], [45, 47], [53, 52], [76, 79], [64, 61], [31, 34], [30, 29], [74, 74], [7, 6], [23, 26], [17, 14], [55, 58], [3, 1], [63, 64], [41, 43], [34, 33], [28, 25], [79, 77], [47, 45], [71, 73], [14, 11], [8, 9], [51, 54], [22, 19], [27, 30], [40, 38], [70, 67], [25, 23], [4, 5], [50, 50], [13, 16]], [undef, undef, 29, 46, 62, 12, 17, 42, 55, undef, 8, 18, 3, 64, 54, 24, undef, 44, 9, 32, undef, 23, 57, 43, 2, 61, 15, 58, 50, 22, 40, 39, 6, undef, 49, 25, 34, undef, 16, 0, 59, 48, 33, undef, 11, 35, undef, 52, 21, 5, 63, 56, 28, 36, 13, 45, undef, 30, undef, 1, 27, 10, undef, 47, 38, 4, 26, undef, 20, 31, 60, 53, 7, 14, 41, undef, 37, 19, undef, 51], [undef, 46, undef, 17, 29, 62, 42, 8, 12, 55, 18, 54, 24, undef, 44, 3, 64, 9, undef, 57, 32, 2, undef, 61, 23, 50, 43, 15, undef, 40, 58, 6, 22, 49, 39, 16, 25, undef, 59, 34, 33, 0, undef, 48, 11, 52, undef, 35, 5, 28, 63, 21, 36, undef, 56, 13, 1, undef, 45, 27, 30, 38, 10, undef, 47, 26, undef, 60, 4, 20, 7, undef, 31, 53, 41, 19, 14, 51, undef, 37]];

echo(railing_100=railing_100);
railing(railing_100);
