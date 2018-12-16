use <math.scad>;

$fn = 12;

function _echo(x,s) = [x, search([str(s)], [])][0];
function _assert(m,x,v) = x?v:_echo(v, str(m));
function _value(n,v) = _echo(v, str(n,"=",v));
function _func(n,a) = _echo(undef, str(n,"(",_args(a),")"));
function _args(a,i=0,s="") = i>=len(a)?s:_args(a,i+2,i==0?str(a[0],"=",a[1]):str(s,", ",a[i],"=",a[i+1]));

e = exp(1);

function feet(ft,in=0) = inches(ft*12+in);
function inches(in) = in;

function max_tilt_offset() = 3;
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
function v_normstd(v,avg=undef) = len(v) <= 1 ? 0 : let(a=avg!=undef?avg:v_avg(v)) v_std(v,a)/a;
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
function balusters_gaps(b) = b[11];
function balusters_avgaps(b) = b[12];
function balusters_avgapszg(b) = b[13];
function balusters_score_terms(b) = b[14];
function balusters_score(b) = b[15];

function balusters_maps(b) = [balusters_bottom_map(b), balusters_top_map(b)];
function balusters_max_tilt(b) = balusters_tilt(b, balusters_max_tilt_offset(b));
function balusters_tilt(b, o) = atan(o*balusters_hres(b)/balusters_vspan(b));
function balusters_max_spacing(b) = balusters_max_gap(b)+baluster_diameter();

function balusters_new(hspan, vspan, hres=horizontal_resolution(), vres=vertical_resolution(), max_tilt_offset=max_tilt_offset(), max_gap=max_gap(), initial_seed=undef, next_seed=undef) =
        let(is=initial_seed!=undef?initial_seed:floor(rands(0,1000000,1)[0]),
            ns=next_seed!=undef?next_seed:rv(1,is)[0])
        balusters_load([hspan, vspan, hres, vres, max_tilt_offset, max_gap, is, ns, []]);

function balusters_dump(b) = [for (i=[0:8]) b[i]];

function build_map(n, rods, k, i=0, j=0, m=[]) =
        let(r = rods[j],
            match = r[k] == i)
        i >= n ? m : build_map(n, rods, k, i+1, match ? j+1 : j, concat(m, [match ? r[2] : undef]));

function balusters_slots(b) = floor(balusters_hspan(b)/balusters_hres(b));

function balusters_load(b, next_seed=undef, rods=undef) =
        let(hspan = balusters_hspan(b),
            hres = balusters_hres(b),
            slots = balusters_slots(b), // leaves at least hres/2 for margins
            erods = rods != undef ? vquicksort(0, rods) : balusters_rods(b),
            maps = [for (i=[0,1]) build_map(slots, vquicksort(i, [for (j=[0:len(erods)-1]) concat(erods[j],j)]), i)])
        concat([for (i=[0:6]) b[i]],
               [next_seed != undef ? next_seed : balusters_next_seed(b),
                erods],
               maps,
               let(crossings = calc_crossings(b, erods),
                   crossings0 = calc_crossings(b, erods, diameter=0),
                   hgaps = calc_hgaps(crossings),
                   hgaps0 = calc_hgaps(crossings0, diameter=0),
                   vgaps = calc_vgaps(hgaps),
                   vgaps0 = calc_vgaps(hgaps0),
                   avgaps = calc_aggregate_vgaps(b, vgaps),
                   avgapszg = calc_aggregate_vgaps(b, vgaps, min_gap=0),
                   avgaps0 = calc_aggregate_vgaps(b, vgaps0, diameter=0),
                   avgaps0zg = calc_aggregate_vgaps(b, vgaps0, diameter=0, min_gap=0),
                   agaps0zg = calc_aggregate_gaps(b, avgaps0zg, diameter=0, min_gap=0),
                   gaps = calc_gaps(b, avgaps),
                   vspan = balusters_vspan(b),
                   vres = balusters_vres(b),
                   max_spacing = balusters_max_gap(b) + baluster_diameter(),
                   max_tilt_offset = balusters_max_tilt_offset(b),
                   intersections = [for (ag=agaps0zg) if (len(ag)>1) for (t=tuples(2,ag)) let(a=t[0][len(t[0])-1],b=t[1][0]) [((a[1]+a[0])/2+(b[1]+b[0])/2)/2, (a[2]+b[2])/2]],
                   intersection_height_histogram = [for (g=vgroupby(1,vquicksort(1,intersections))) [g[0][1], len(g)]],
                   rod_tilts = [for (i=[0,1]) let(m=maps[i],j=abs(i-1)) [for (s=m) if (s!=undef) let(r=erods[s]) r[j]-r[i]]],
                   rod_tilt_deltas = [for (rt=rod_tilts) [for (p=tuples(2,rt)) p[1]-p[0]]],
                   rod_tilt_trends = [for (rtd=rod_tilt_deltas) v_sum([for (p=tuples(2,rtd)) p[1]==p[0] ? 1 : (sign(p[1])==sign(p[0]) ? 0.1 : 0)])],
                   rod_tilt_histogram = [for (g=vgroupby(0,vquicksort(0,[for (r=erods) [r[1]-r[0], r]]))) [g[0][0], len(g)]],
                   intersection_hgaps = [for (t=tuples(2,concat([0],[for (i=intersections) i[0]],[hspan]))) t[1]-t[0]],
                   intersection_vgaps = [for (t=tuples(2,intersections)) t[1][1]-t[0][1]],
                   intersection_vgap_deltas = [for (vgp=tuples(2,intersection_vgaps)) vgp[1]-vgp[0]],
                   intersection_valign_count = v_sum([for (ivg=intersection_vgaps) if(abs(ivg)<=2*vres) 1]),
                   intersection_vtrend_count = v_sum([for (ivgd=intersection_vgap_deltas) if(abs(ivgd)<=2*vres) 1]),
                   rod_pitch = max_spacing*3/5,
                   intersection_pitch=hspan/(6*rod_pitch),
                   terms=let(t=[
                    "avoid_parallel_runs", let(prv=[for (avg=avgaps0zg) for (ag=avg) let(ab=ag[1],a=erods[ab[0]],b=erods[ab[1]],at=a[1]-a[0],bt=b[1]-b[0]) if (a!=undef && b!=undef && at == bt) let(x=len(ag[0])/len(hgaps0),sx=squash(0.7,x)) [sx, x]], x=v_sum([for (pr=prv) pr[0]]), sx=x) [sx, x, prv],
                    "rod_tilt_diversity", let(offsets=2*max_tilt_offset,x=(offsets-len(rod_tilt_histogram))*len(erods)/offsets+v_std([for (b=rod_tilt_histogram) b[1]]), sx=squash(0.7,x)) [sx, x, offsets, len(rod_tilt_histogram), rod_tilt_histogram],
                    "std_hgaps", let(v=[for (vg=vgaps0) v_avg([for (g=vg) g[0][1]-g[0][0]])/rod_pitch], x=v_std(v,1), sx=10*squash(0.1,x)) [sx, x, rod_pitch, v],
                    "std_intersection_hgaps", let(v=[for (g=intersection_hgaps) g/intersection_pitch], x=v_std(v,1), sx=10*squash(0.1,x)) [sx, x, intersection_pitch, v],
                    "intersection_valign_count", [intersection_valign_count],
                    "intersection_vtrend_count", [intersection_vtrend_count],
                    "rod_tilt_trends", let(st=[for (t=rod_tilt_trends) squash(0.7,t)],x=v_avg(st),sx=x) [sx, x, st, rod_tilt_trends],
                    "dummy", [0]]) [for (i=[0:len(t)-3]) t[i]],
                   score=v_sum([for (i=[1:2:len(terms)-1]) terms[i][0]]))
               [gaps,
                avgaps,
                avgapszg,
                terms,
                score]);

function balusters_margin(b) =
        let(hspan = balusters_hspan(b),
            hres = balusters_hres(b),
            slots = balusters_slots(b))
        (hspan-hres*(slots-1))/2;

function balusters_check_rod(b, rod) =
        let(maps=balusters_maps(b),
            tests=[for (i=[0,1]) let(r=rod[i],m=maps[i]) 0 <= r && r < len(m) && m[r] == undef])
        tests[0] && tests[1];

function balusters_add(b, next_seed, rod) =
        balusters_load(b, next_seed=next_seed, rods=concat(balusters_rods(b), [rod]));

function balusters_remove(b, next_seed, rod) =
        balusters_load(b, next_seed=next_seed, rods=[for (r=balusters_rods(b)) if (r!=rod) r]);

function balusters_remove_all(b, next_seed_rod_v, i=0) = // TODO: make this a join-style filter
        i >= len(next_seed_rod_v) ? b :
        balusters_remove_all(balusters_remove(b, next_seed_rod_v[i][0], next_seed_rod_v[i][1]), next_seed_rod_v, i+1);

// Vector of crossings at each level dictated by vres, as vectors of [x, y, rod_index] in ascending order of x position.
function calc_crossings(b, rods, diameter=baluster_diameter(), i=0, result=[]) =
        let(vspan = balusters_vspan(b),
            vres = balusters_vres(b),
            n = round(vspan/vres),
            evres = vspan/n)
        i > n ? result
        : calc_crossings(
                b, rods, diameter, i+1,
                concat(result,
                       [let(margin = balusters_margin(b),
                            hres = balusters_hres(b),
                            y = i*evres)
                        concat([[-diameter/2, y, -1]],
                               len(rods) == 0 ? [] : vquicksort(0, [for (ri=[0:len(rods)-1]) let(r=rods[ri]) [margin + hres*r[0] + hres*(r[1]-r[0])*y/vspan, y, ri]]),
                               [[balusters_hspan(b)+diameter/2, y, len(rods)]])]));

// Gaps in a set of balusters, as a vector of horizontal rows of [[min_x, max_x, y], [min_rod_index, max_rod_index]]
function calc_hgaps(crossings, diameter=baluster_diameter()) =
        [for (c=crossings)
                [for (t=tuples(2,c))
                        let (a=t[0],b=t[1])
                                [[a[0]+diameter/2, b[0]-diameter/2, a[1]], [a[2], b[2]]]]];

// Gaps in a set of balusters, as a vector of vertical columns of [[min_x, max_x, y], [min_rod_index, max_rod_index]]
function calc_vgaps(hgaps) =
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
function calc_aggregate_vgaps(b, vgaps, diameter=baluster_diameter(), min_gap=undef) =
        let(emin_gap = min_gap!=undef?min_gap:balusters_max_gap(b),
            vres = balusters_vres(b))
        [for (vg=vgaps)
                [for (ag=aggregate_vgaps(vg, min_gap=emin_gap)) let(yg=ag[0][len(ag[0])-1][2]-ag[0][0][2]) if (vres*ceil(yg/vres)>=emin_gap/2) ag]];

// Aggregates vgaps in a vertical column into a vector of [[min_x, max_x, min_y], ... [min_x, max_x, max_y]], separated by intersections
function aggregate_gaps(v, i=0, result=[]) =
        i >= len(v)
        ? result
        : aggregate_gaps(v, i+1,
                let(n = v[i],
                    pr = i==0 ? undef : v[i-1][1],
                    nr = n[1])
                   pr == undef || (pr[0] == nr[1] && pr[1] == nr[0]) // new or intersection
                   ? concat(result, [n[0]])
                   : v_set(result, len(result)-1, concat(result[len(result)-1], n[0])));

// Gaps in a set of balusters, as a vector of vertical columns of [[min_x, max_x, min_y], ... [min_x, max_x, max_y]], separated by intersections
function calc_aggregate_gaps(b, avgaps, diameter=baluster_diameter(), min_gap=undef) =
        let(emin_gap = min_gap!=undef?min_gap:balusters_max_gap(b),
            vres = balusters_vres(b))
        [for (avg=avgaps)
                [for (ag=aggregate_gaps(avg)) let(yg=ag[len(ag[0])-1][2]-ag[0][2]) if (vres*ceil(yg/vres)>=emin_gap/2) ag]];

// Gaps in a set of balusters, as a vector of [area, [[min_x, max_x, min_y], ... [min_x, max_x, max_y]], [min_rod_index, max_rod_index]]
function calc_gaps(b, avgaps) =
        let(vres = balusters_vres(b))
        [for (avg=avgaps)
                for (ag=avg) concat([v_sum([for (g=ag[0]) (g[1]-g[0])*vres])], ag)];

function fill_gap(b, gaps, removed_rod=undef) =
        let(_f=_func("fill_gap",["b",balusters_dump(b)]),
            gap = gaps[0], // smallest gap
//            gap = gaps[len(gaps)-1], // largest gap
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
            candidate_rods = [for (tobi=tilt_offset_bottom_intercepts) let(bottom_slot=round((tobi[1]-margin)/hres)) [bottom_slot, bottom_slot+tobi[0]]],
            valid_rods = [for (cr=candidate_rods) if (cr != removed_rod && balusters_check_rod(b, cr)) cr],
            rrv = rv(len(valid_rods),seed=rv[0]),
            candidates = len(valid_rods) == 0 ? [] : [for (i=[0:len(valid_rods)-1]) balusters_add(b, rrv[i], valid_rods[i])],
            scored_candidates = vquicksort(0, [for (c=randomize(candidates,rv[1])) [balusters_score(c), c]]))
        len(scored_candidates) == 0 ? undef : randomize([for (i=[0:min(len(scored_candidates),1)]) scored_candidates[i][1]],rv[2])[0];

function remove_rods(b) =
        let(_f=_func("remove_rods",["b",balusters_dump(b)]),
            rv = rv(3,balusters_next_seed(b)),
            rods = balusters_rods(b),
            candidate_tuples = tuples(3,rods),
            rrv = rv(len(candidate_tuples),seed=rv[0]),
            candidates = [
                    for (i=[0:len(candidate_tuples)-1])
                        let(t = candidate_tuples[i],
                            rrv2 = rv(len(t),seed=rrv[i]),
                            c = fill_gaps(balusters_remove_all(b, [for (i=[0:len(t)]) [rrv2[i], t[i]]]), fill_only=true))
                                [balusters_score(c), c]])
        vquicksort(0, candidates)[0][1];

function fill_gaps(b,fill_only=false) =
        let(_f=_func("fill_gaps",["b",balusters_dump(b),"fill_only",fill_only]),
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
            max_balusters = round(2*hspan/(max_gap+diameter)) - 1,
            fill = _value("fill",len(rods)/max_balusters),
            b2 = len(gaps) == 0 && (fill_only || score <= 0) ? b : (len(rods) < max_balusters ? (let(b3=fill_gap(b, gaps)) b3 != undef ? b3 : remove_rods(b)) : remove_rods(b)))
        b2 == b ? b : fill_gaps(b2,fill_only=fill_only);

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

    echo(score=balusters_score(b));

    score_terms = balusters_score_terms(b);
    for (i=[0:2:len(score_terms)-1]) {
        echo("score:",name=score_terms[i],value=score_terms[i+1]);
    }

    gaps = vquicksort(0, [for (avg=balusters_avgapszg(b)) for (ag=avg) let(sg=vquicksort(0, [for (g=ag[0],bot=ag[0][0][2],top=ag[0][len(ag[0])-1][2]) if ((bot+max_gap/2) <= g[2] && g[2] <= (top-max_gap/2)) [g[1]-g[0], (g[0]+g[1])/2, g[2]]])) sg[len(sg)-1]]);
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

    if (show_gaps||true) {
        avgaps = balusters_avgaps(b);
        for (avg = avgaps) {
            for (ag = avg) {
                rotate([90,0,0]) {
                    translate([0,0,-baluster_diameter()/2]) {
                        color("green", 0.5) {
                            linear_extrude(baluster_diameter()) {
                                polygon(concat([for (g=ag[0]) [g[0],g[2]]],
                                               [for (i=[len(ag[0])-1:-1:0]) let(g=ag[0][i]) [g[1],g[2]]]));
                            }
                        }
                    }
                }
            }
        }

        echo(gap_count=len(balusters_gaps(b)));
        gaps = vquicksort(0, [for (avg=avgaps) for (ag=avg) let( sg=vquicksort(0, [for (g=ag[0]) if ((max_gap/2) <= g[2] && g[2] <= (vspan-max_gap/2)) [g[1]-g[0], (g[0]+g[1])/2, g[2]]]))
                                                                    sg[len(sg)-1]]);
        if (len(gaps) > 0) {
            for (g=[for (i=[max(0,len(gaps)-5):len(gaps)-1]) gaps[i]]) {
                if (g[0]>max_gap) {
                    translate([g[1],0,g[2]]) {
                        color(g[0]>max_gap?"red":"black",0.3) sphere(d=inches(4/*max_gap*/),$fn=30);
                    }
                }
            }
        }
    }
}

module railing(b,show_gaps=false) {
    hres = balusters_hres(b);
    margin = balusters_margin(b);
    hspan = balusters_hspan(b);
    vspan = balusters_vspan(b);
    max_gap = balusters_max_gap(b);
    max_spacing = balusters_max_spacing(b);
    rods = balusters_rods(b);

    translate([0, 0, bottom_rail_height()]) {
        balusters(b,show_gaps=show_gaps);
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


function squash(t,x) = let(y=log(1+exp((x-1)*2*e))) t==0 ? y : y-squash(t=0,x=t);
function squashed_normstd(a,v) = squash(a/len(v), v_normstd(v));

function countzeros(v, threshold=0, i=0, count=0, maxcount=0) =
        i >= len(v) ? maxcount
        : countzeros(v, threshold, i+1, abs(v[i])<=threshold?count+1:0, max(count, maxcount));

function randomize(v, seed) =
        len(v) == 0 ? []
        : (let(rv=rv(len(v),seed))
           [for (p=vquicksort(0, [for (i=[0:len(v)-1]) [rv[i], v[i]]])) p[1]]);

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


initial_seed=undef;
function horizontal_resolution() = inches(3/4);
horizontal_span=inches(92+3/4);
//horizontal_span=inches(30);

r=

[92.75, 31.5, 0.75, 0.75, 3, 3.375, 643739, 0.541155, [[4, 1], [6, 8], [7, 4], [9, 11], [12, 13], [15, 17], [18, 19], [21, 18], [24, 22], [25, 26], [28, 31], [31, 28], [34, 33], [37, 39], [39, 36], [40, 43], [43, 42], [46, 45], [51, 49], [52, 55], [55, 53], [58, 57], [62, 60], [63, 66], [64, 63], [69, 68], [71, 72], [74, 71], [76, 77], [81, 79], [83, 85], [84, 82], [88, 89], [91, 94], [93, 91], [95, 97], [100, 99], [104, 106], [105, 102], [108, 105], [110, 113], [111, 109], [115, 116], [118, 121]]]

//undef

;

railing = r==undef ? fill_gaps(balusters_new(horizontal_span,vertical_span(),initial_seed=initial_seed)) : balusters_load(r);


echo(str("railing = balusters_load(",balusters_dump(railing),");"));

balusters_report(railing);

//rotate([0,0,-90]) {
//    instructions(railing);

    translate([0, -feet(2), inches(12)]) {
        railing(railing, show_gaps=false);
    }
//}

