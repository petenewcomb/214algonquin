// Run with:
// time openscad -o /tmp/railing.echo railing.scad & pid=$!; sleep 1; tail -n +0 -f /tmp/railing.echo | sed -r -e 's/^  WARNING: search term not found: "(.*)"$/\1/' -e 's/^ECHO: "(.*:)", name = "(.*)", value = (.*)$/\1 \2 = \3/' -e 's/^ECHO: "(.*)"$/\1/' -e 's/^ECHO: (.*)$/\1/' & tpid=$!; sleep 1; wait $pid; kill $tpid

use <math.scad>;

$fn = 12;

function _echo(x,s) = [x, search([str(s)], [])][0];
function _assert(m,x,v) = x?v:_echo(v, str(m));
function _value(n,v) = _echo(v, str(n," = ",v));
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
function balusters_growth_increment(b) = b[7];
function balusters_next_seed(b) = b[8];
function balusters_rods(b) = b[9];
function balusters_bottom_map(b) = b[10];
function balusters_top_map(b) = b[11];
function balusters_gaps(b) = b[12];
function balusters_avgaps(b) = b[13];
function balusters_avgapszg(b) = b[14];
function balusters_score_terms(b) = b[15];
function balusters_score(b) = b[16];

function balusters_maps(b) = [balusters_bottom_map(b), balusters_top_map(b)];
function balusters_max_tilt(b) = balusters_tilt(b, balusters_max_tilt_offset(b));
function balusters_tilt(b, o) = atan(o*balusters_hres(b)/balusters_vspan(b));
function balusters_max_spacing(b) = balusters_max_gap(b)+baluster_diameter();

function balusters_rod_pitch(b) = balusters_max_spacing(b)*23/40;
function balusters_intersection_pitch(b) = let(ideal=5*balusters_rod_pitch(b),hspan=balusters_hspan(b)) hspan/floor(hspan/ideal);
function balusters_max_growth_increment(b) = round(balusters_hspan(b)/balusters_intersection_pitch(b)) - 2;
function balusters_growth_hspan(b) = let(i=balusters_growth_increment(b)) i < 0 ? balusters_hspan(b) : (2+i)*balusters_intersection_pitch(b);

function balusters_new(hspan, vspan, hres=horizontal_resolution(), vres=vertical_resolution(), max_tilt_offset=max_tilt_offset(), max_gap=max_gap(), initial_seed=undef, next_seed=undef) =
        let(is=initial_seed!=undef?initial_seed:floor(rands(0,1000000,1)[0]),
            ns=next_seed!=undef?next_seed:rv(1,is)[0])
        balusters_load([hspan, vspan, hres, vres, max_tilt_offset, max_gap, is, 0, ns, []]);

function balusters_dump(b) = [for (i=[0:9]) b[i]];

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
            maps = [for (i=[0,1]) build_map(slots, len(erods) == 0 ? [] : vquicksort(i, [for (j=[0:len(erods)-1]) concat(erods[j],j)]), i)],
            b2 = concat([for (i=[0:6]) b[i]],
                    [let(gi=balusters_growth_increment(b),mgi=balusters_max_growth_increment(b)) mgi >= 0 && gi < balusters_max_growth_increment(b) ? gi : -1,
                     next_seed != undef ? next_seed : balusters_next_seed(b),
                     erods],
                    maps))
        concat(b2,
               // calculate score
               let(crossings = calc_crossings(b2, erods),
                   crossings0 = calc_crossings(b2, erods, diameter=0),
                   hgaps = calc_hgaps(crossings),
                   hgaps0 = calc_hgaps(crossings0, diameter=0),
                   vgaps = calc_vgaps(hgaps),
                   vgaps0 = calc_vgaps(hgaps0),
                   avgaps = calc_aggregate_vgaps(b2, vgaps),
                   avgapszg = calc_aggregate_vgaps(b2, vgaps, min_gap=0),
                   avgaps0 = calc_aggregate_vgaps(b2, vgaps0, diameter=0),
                   avgaps0zg = calc_aggregate_vgaps(b2, vgaps0, diameter=0, min_gap=0),
                   agaps0zg = calc_aggregate_gaps(b2, avgaps0zg, diameter=0, min_gap=0),
                   gaps = calc_gaps(b2, avgaps),
                   growth_hspan = balusters_growth_hspan(b2),
                   vspan = balusters_vspan(b2),
                   vres = balusters_vres(b2),
                   max_spacing = balusters_max_spacing(b2),
                   max_tilt_offset = balusters_max_tilt_offset(b2),
                   intersections = [for (ag=agaps0zg) if (len(ag)>1) for (t=tuples(2,ag)) let(a=t[0][len(t[0])-1],b=t[1][0]) [((a[1]+a[0])/2+(b[1]+b[0])/2)/2, (a[2]+b[2])/2]],
                   rod_tilts = [for (i=[0,1]) let(m=maps[i],j=abs(i-1)) [for (s=m) if (s!=undef) let(r=erods[s]) r[j]-r[i]]],
                   rod_tilt_deltas = [for (rt=rod_tilts) [for (p=tuples(2,rt)) p[1]-p[0]]],
                   rod_tilt_trends = [for (rtd=rod_tilt_deltas) rod_tilt_trends(rtd)], //[for (p=tuples(2,rtd)) p[1]-p[0]]],
                   rod_tilt_histogram = [for (g=vgroupby(0,vquicksort(0,[for (r=erods) [r[1]-r[0], r]]))) [g[0][0], len(g)]],
                   intersection_hgaps = [for (t=tuples(2,concat([0],[for (i=intersections) i[0]],[growth_hspan]))) t[1]-t[0]],
                   intersection_vgaps = [for (t=tuples(2,intersections)) t[1][1]-t[0][1]],
                   intersection_vgap_deltas = [for (vgp=tuples(2,intersection_vgaps)) vgp[1]-vgp[0]],
                   intersection_valign_count = v_sum([for (ivg=intersection_vgaps) if(abs(ivg)<=2*vres) 1]),
                   intersection_vtrend_count = v_sum([for (ivgd=intersection_vgap_deltas) if(abs(ivgd)<=2*vres) 1]),
                   rod_pitch = balusters_rod_pitch(b2),
                   target_gap_count = growth_hspan/rod_pitch,
                   intersection_pitch = balusters_intersection_pitch(b2),
                   target_intersection_gap_count=growth_hspan/intersection_pitch,
                   terms=let(t=[
                    "avoid_parallel_runs", let(prv=[for (avg=avgaps0zg) v_max([for (ag=avg) let(ab=ag[1],a=erods[ab[0]],b=erods[ab[1]],at=a[1]-a[0],bt=b[1]-b[0]) a==undef || b==undef || at != bt ? 0 : len(ag[0])/len(hgaps0)])], tups=[for (t=tuples(10,prv)) v_sum(t)], x=len(tups)==0?0:v_avg(tups), sx=squash(x/10,0.14)) [sx, x, prv],
                    "rod_tilt_diversity", let(offsets=2*max_tilt_offset,h=[for (b=[0:offsets-1]) b < len(rod_tilt_histogram) ? rod_tilt_histogram[b][1] : 0],x=len(erods)>0?v_std(h)/(len(erods)/offsets):0, sx=squash(x/10,0.1)) [sx, x, len(erods), offsets, h, rod_tilt_histogram],
                    "bias", let(x=v_avg(rod_tilts[0]),sx=squash(abs(x),0.2)) [sx, x, rod_tilts[0]],
                    "bias2", let(v=[for (tilt=rod_tilts[0]) sign(tilt)],x=v_sum(v),sx=squash(abs(x)/10,0.1)) [sx, x, v],
                    "density", let(gap_count=len(erods)+1,x=abs(target_gap_count-gap_count)/target_gap_count,sx=squash(x,0.01,0.01)) [sx, x, gap_count, target_gap_count],
                    "intersection_density", let(intersection_gap_count=len(intersections)+1,x=abs(target_intersection_gap_count-intersection_gap_count)/target_intersection_gap_count,sx=squash(x,0.01,0.01)) [sx, x, intersection_gap_count, target_intersection_gap_count],
                    "std_hgaps", let(v=[for (vg=vgaps0) v_avg([for (g=[vg[0],vg[len(vg)-1]]) let(w=g[0][1]-g[0][0]) if (w<=max_spacing) w])/rod_pitch], x=v_std(v,1), sx=squash(x,0.15)) [sx, x, rod_pitch, v],
                    "std_rail_hgaps", let(v=[for (vg=vgaps0) v_avg([for (g=vg) let(w=g[0][1]-g[0][0]) if (w<=max_spacing) w])/rod_pitch], x=v_std(v,1), sx=squash(x,0.1)) [sx, x, rod_pitch, v],
                    "std_intersection_hgaps", let(v=[for (g=intersection_hgaps) g/intersection_pitch], x=v_std(v,1), sx=squash(x,0.3)) [sx, x, intersection_pitch, v],
                    "std_intersection_heights", let(v=[for (i=intersections) i[1]-vspan/2],x=abs(v_sum(v)/vspan),sx=squash(x,0.5)) [sx, x, v, intersections],
                    "intersection_valign_count", [intersection_valign_count],
                    "intersection_vtrend_count", [intersection_vtrend_count],
                    "rod_tilt_trends", let(v=[for (v=rod_tilt_trends) for (t=v) len(t)],x=v_std(v,1.2),sx=squash(x,0.4)) [sx, x, v_avg(v), v, rod_tilt_trends],
                    "ignored", [0]]) [for (i=[0:len(t)-3]) t[i]],
                   score=v_sum([for (i=[1:2:len(terms)-1]) terms[i][0]]))
               [gaps,
                avgaps,
                avgapszg,
                terms,
                score]);

function rod_tilt_trends(v, i=0, result=[]) =
        i >= len(v) ? result
        : rod_tilt_trends(v, i+1,
                (len(result) == 0 || (v[i] != 0 && (let(trend=result[len(result)-1]) sign(trend[0]) != sign(v[i])))
                 ? concat(result, len(result) > 0 && (let(trend=result[len(result)-1]) trend[len(trend)-1] == 0) ? [[0, v[i]]] : [[v[i]]])
                 : (let(trend=result[len(result)-1])
                    v_set(result, len(result)-1, concat(trend, [v[i]])))));

function balusters_margin(b) =
        let(hspan = balusters_hspan(b),
            hres = balusters_hres(b),
            slots = balusters_slots(b))
        (hspan-hres*(slots-1))/2;

function balusters_check_rod(b, rod) =
        let(maps=balusters_maps(b),
            tests=[for (i=[0,1]) let(r=rod[i],m=maps[i]) 0 <= r && r < len(m) && m[r] == undef])
        tests[0] && tests[1];

function balusters_grow(b) =
        balusters_load([for (i=[0:9]) i != 7 ? b[i] : (b[i] < 0 ? b[i] : b[i]+1)]);

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
                               [[balusters_growth_hspan(b)+diameter/2, y, len(rods)]])]));

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
//            gap = gaps[0], // smallest gap
            gap = gaps[len(gaps)-1], // largest gap
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
            candidate_tuples = (
                    let(margin=balusters_margin(b),
                        threshold=max(0, balusters_growth_hspan(b)-2.5*balusters_intersection_pitch(b)-balusters_margin(b)),
                        min_slot=ceil(threshold/balusters_hres(b)))
                    tuples(3,[for (r=rods) if (r[0]>=min_slot || r[1]>=min_slot) r])),
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
            len_rods = _value("len(rods)",len(rods)),
            fill = _value("fill",len(rods)/round(balusters_hspan(b)/balusters_rod_pitch(b)-1)),
            b2 = len(gaps) == 0 && (fill_only || score <= 0) ? (fill_only || balusters_growth_increment(b) < 0 ? b : balusters_grow(b)) : (let(b3=fill_gap(b, gaps)) b3 != undef ? b3 : remove_rods(b)))
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

    echo(gap_count=len(balusters_gaps(b)));

    gaps = vquicksort(0, [for (avg=balusters_avgapszg(b)) for (ag=avg) let(sg=vquicksort(0, [for (g=ag[0],bot=ag[0][0][2],top=ag[0][len(ag[0])-1][2]) if ((bot+max_gap/2) <= g[2] && g[2] <= (top-max_gap/2)) [g[1]-g[0], (g[0]+g[1])/2, g[2]]])) sg[len(sg)-1]]);
    if (len(gaps) > 0) {
        for (g=[for (i=[max(0,len(gaps)-5):len(gaps)-1]) gaps[i]]) {
            echo(g=g);
        }
    }
}

module balusters(b,socket_depth=baluster_socket_depth(),cubes=false,show_gaps=false,extra_tilt_spacing=0) {
    hres = balusters_hres(b);
    margin = balusters_margin(b);
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
                    translate([0, sign(a)*(baluster_diameter()+extra_tilt_spacing)/2, -socket_depth]) {
                        color([0.4,0.4,0.4]) {
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

module railing(b,show_gaps=false,left_post=true,right_post=true,alpha=0.8) {
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
        color(walnut(),alpha) cube([hspan,top_rail_width(),top_rail_height()]);
    }

    // bottom rail
    translate([0,-bottom_rail_width()/2,0]) {
        color(walnut(),alpha) cube([hspan,bottom_rail_width(),bottom_rail_height()]);
    }

    if (left_post) {
        // left post
        translate([-post_width(),-post_width()/2,-inches(3)]) {
            color(walnut(),alpha) cube([post_width(),post_width(),post_height()]);
        }
    }

    if (right_post) {
        // right post
        translate([hspan,-post_width()/2,-inches(3)]) {
            color(walnut(),alpha) cube([post_width(),post_width(),post_height()]);
        }
    }
}

// Squashing function based on f(x) = ln(1+exp(x-1))
//   0 <= threshold < 1
//   0 <= inflection < 1
// raw input: -inf threshold 1 +inf
// norm input: -inf f^-1(inflection) f^-1(1+inflection) +inf
// output: -inflection 0 1 +inf
//
// See: https://www.desmos.com/calculator/dkebbgcnfp
//
function squash(x, threshold=0, inflection=0.01) =
        let(normalized_inflection = 1 + ln(exp(inflection)-1),
            normalized_1 = 1 + ln(exp(1+inflection)-1),
            normalized_range = normalized_1 - normalized_inflection,
            normalized_x = normalized_inflection + (x-threshold) * normalized_range / (1-threshold))
        ln(1+exp(normalized_x-1)) - inflection;

/*
threshold=0;
inflection=0.1;
echo(squash_n10=squash(-10, threshold=threshold, inflection=inflection));
echo(squash_n1=squash(-1, threshold=threshold, inflection=inflection));
echo(squash_n0_1=squash(-0.1, threshold=threshold, inflection=inflection));
echo(squash_0=squash(0, threshold=threshold, inflection=inflection));
echo(squash_0_0099=squash(0.0099, threshold=threshold, inflection=inflection));
echo(squash_0_01=squash(0.01, threshold=threshold, inflection=inflection));
echo(squash_0_02=squash(0.02, threshold=threshold, inflection=inflection));
echo(squash_0_099=squash(0.099, threshold=threshold, inflection=inflection));
echo(squash_0_1=squash(0.1, threshold=threshold, inflection=inflection));
echo(squash_0_2=squash(0.2, threshold=threshold, inflection=inflection));
echo(squash_0_99=squash(0.99, threshold=threshold, inflection=inflection));
echo(squash_1=squash(1, threshold=threshold, inflection=inflection));
echo(squash_2=squash(2, threshold=threshold, inflection=inflection));
echo(squash_3=squash(2, threshold=threshold, inflection=inflection));
echo(squash_9=squash(2, threshold=threshold, inflection=inflection));
echo(squash_10=squash(2, threshold=threshold, inflection=inflection));
echo(squash_11=squash(2, threshold=threshold, inflection=inflection));
*/

function countzeros(v, threshold=0, i=0, count=0, maxcount=0) =
        i >= len(v) ? maxcount
        : countzeros(v, threshold, i+1, abs(v[i])<=threshold?count+1:0, max(count, maxcount));

function randomize(v, seed) =
        len(v) == 0 ? []
        : (let(rv=rv(len(v),seed))
           [for (p=vquicksort(0, [for (i=[0:len(v)-1]) [rv[i], v[i]]])) p[1]]);

module instructions(b) {
    rotate([0,0,-90]) {

        hspan=balusters_hspan(b);
        vspan=balusters_vspan(b);
        hres=balusters_hres(b);
        margin=balusters_margin(b);
        maps=balusters_maps(b);
        rods=balusters_rods(b);

        dashlen=baluster_diameter()*2/3;
        dashwidth=baluster_diameter()/8;

        color("black") {
            projection(cut=true) {
                difference() {
                    // bottom rail
                    translate([0,-bottom_rail_width()/2,-inches(1)]) {
                        cube([hspan,bottom_rail_width(),inches(2)]);
                    }
                    balusters(b,extra_tilt_spacing=hres-baluster_diameter());

                    translate([margin-dashlen/2,-dashwidth/2,-inches(2)]) {
                        m=maps[0];
                        for (i=[0:len(m)-1]) {
                            tilt = m[i]==undef ? 0 : let(r=rods[m[i]]) r[1]-r[0];
                            if (tilt <= 0) {
                                translate([i*hres,hres/2,0]) cube([dashlen,dashwidth,inches(4)]);
                            }
                            if (tilt >= 0) {
                                translate([i*hres,-hres/2,0]) cube([dashlen,dashwidth,inches(4)]);
                            }
                        }
                    }
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
                                balusters(b,extra_tilt_spacing=hres-baluster_diameter());
                            }

                            translate([margin-dashlen/2,-dashwidth/2,-inches(2)]) {
                                m=maps[1];
                                for (i=[0:len(m)-1]) {
                                    tilt = m[i]==undef ? 0 : let(r=rods[m[i]]) r[1]-r[0];
                                    if (tilt <= 0) {
                                        translate([i*hres,hres/2,0]) cube([dashlen,dashwidth,inches(4)]);
                                    }
                                    if (tilt >= 0) {
                                        translate([i*hres,-hres/2,0]) cube([dashlen,dashwidth,inches(4)]);
                                    }
                                }
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
                translate([-1*hres-hres*(balusters_max_tilt_offset(b)-o),bottom_rail_width()/2+4*hres+vspan/2,0]) {
                    rotate([0,0,90]) {
                        rod_length=let(x=hres*o,y=vspan+2*socket_depth) norm([x,y]);
                        rod_count=len([for (r=rods) if (abs(r[1]-r[0])==o) r]);
                        text(str(rod_count, " rod(s) of length ", fmt_frac(rod_length), "\" for tilt offset ", o, " (", round(balusters_tilt(b, o)), "°)"),size=font_size,font="Times Roman",halign="center",valign="center");
                    }
                }
                translate([hspan+1*hres,bottom_rail_width()/2+4*hres+vspan/2,0]) {
                    rotate([0,0,90]) {
                        text(str("total length: ", fmt_frac(hspan), "\""),size=font_size,font="Times Roman",halign="center",valign="center");
                    }
                }
            }
            translate([margin,0,0]) {
                for (i=[0,1]) {
                    translate([0,bottom_rail_width()/2+hres*2+i*(hres*5+vspan),0]) {

                        translate([hres*-2,-hres/2,0]) {
                            rotate([0,0,90]) {
                                translate([0,1*hres,0]) text("Tilt",size=font_size,font="Times Roman",halign="center",valign="center");
                                text("Offset",size=font_size,font="Times Roman",halign="center",valign="center");
                                translate([(i*2-1)*(bottom_rail_width()+hres*3)+i*hres,0,0]) {
                                    text("Slot",size=font_size,font="Times Roman",halign="center",valign="center");
                                }
                                translate([(i*2-1)*(bottom_rail_width()+hres*8)+i*hres*1,0,0]) {
                                    translate([0,2*hres,0]) text("From",size=font_size,font="Times Roman",halign="center",valign="center");
                                    translate([0,1*hres,0]) text("End",size=font_size,font="Times Roman",halign="center",valign="center");
                                    text(i==0?"(+)":"(-)",size=font_size,font="Times Roman",halign="center",valign="center");
                                }
                                translate([(i*2-1)*(bottom_rail_width()+hres*13)+i*hres*1,0,0]) {
                                    translate([0,2*hres,0]) text("From",size=font_size,font="Times Roman",halign="center",valign="center");
                                    translate([0,1*hres,0]) text("End",size=font_size,font="Times Roman",halign="center",valign="center");
                                    text(i==0?"(-)":"(+)",size=font_size,font="Times Roman",halign="center",valign="center");
                                }
                            }
                        }

                        m=maps[i];
                        for (j=[0:len(m)-1]) {
                            k = m[j];
                            r=rods[k];
                            tilt=r[abs(i-1)]-r[i];
                            o = k==undef ? "- " : str(tilt>0?"+":"",tilt);
                            translate([hres*j,0,0]) {
                                rotate([0,0,90]) {
                                    text(o,size=font_size,font="Times Roman",halign="right",valign="center");
                                    translate([(i*2-1)*(bottom_rail_width()+hres*3)+i*hres,0,0]) {
                                        text(j==0||j==len(m)-1||k!=undef?str(j+1):"- ",size=font_size,font="Times Roman",halign="right",valign="center");
                                    }
                                    translate([(i*2-1)*(bottom_rail_width()+hres*8)+i*hres*1,0,0]) {
                                        text(k!=undef&&sign(tilt)==-sign(i*2-1)?fmt_frac(margin+hres*j):"- ",size=font_size,font="Times Roman",halign="right",valign="center");
                                    }
                                    translate([(i*2-1)*(bottom_rail_width()+hres*13)+i*hres*1,0,0]) {
                                        text(k!=undef&&sign(tilt)==sign(i*2-1)?fmt_frac(margin+hres*j):"- ",size=font_size,font="Times Roman",halign="right",valign="center");
                                    }
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


initial_seed=undef;
function horizontal_resolution() = inches(3/4);

// stairwell:
//horizontal_span=inches(92+3/4);
//horizontal_span=inches(99+1/8);
//horizontal_span=inches(40+3/8);
//horizontal_span=inches(99+1/2);

// main deck:
//horizontal_span=inches(45+1/2);
//horizontal_span=inches(46+1/4);
//horizontal_span=inches(76+1/2); // 4x
//horizontal_span=inches(59+1/4);
//horizontal_span=inches(59+1/2);

// master deck:
//horizontal_span=inches(11+7/8);
//horizontal_span=inches(55+1/4);
horizontal_span=inches(54+5/8);
//horizontal_span=inches(59+7/8); // 2x

railings=[for (b=[

//// Stairwell

// railing-92_75
[92.75, 31.5, 0.75, 0.75, 3, 3.375, 760766, -1, 0.0499195, [[2, 1], [4, 6], [7, 10], [12, 9], [15, 14], [19, 17], [21, 20], [25, 23], [26, 27], [30, 28], [32, 34], [35, 32], [39, 37], [41, 42], [44, 47], [48, 45], [50, 51], [52, 54], [55, 57], [58, 55], [61, 58], [62, 63], [66, 64], [68, 71], [69, 66], [72, 74], [77, 76], [79, 82], [80, 79], [82, 85], [87, 88], [90, 92], [93, 91], [95, 97], [99, 100], [102, 105], [106, 109], [109, 107], [112, 111], [114, 115], [119, 116], [121, 120]]],

// railing-99
//[99, 31.5, 0.75, 0.75, 3, 3.375, 96679, -1, 0.442657, [[3, 1], [4, 7], [6, 4], [8, 10], [12, 11], [14, 15], [19, 16], [20, 23], [21, 19], [23, 26], [28, 29], [31, 34], [34, 31], [36, 37], [39, 41], [44, 42], [45, 47], [49, 52], [50, 48], [53, 54], [56, 58], [60, 62], [65, 64], [67, 70], [71, 68], [72, 74], [76, 75], [80, 77], [82, 81], [84, 86], [88, 85], [89, 88], [90, 92], [94, 95], [97, 100], [101, 104], [105, 102], [108, 105], [111, 110], [116, 114], [118, 121], [119, 117], [124, 122], [125, 126], [130, 128]]],

// railing-40_25
//[40.25, 31.5, 0.75, 0.75, 3, 3.375, 527737, -1, 0.225115, [[3, 2], [5, 7], [9, 10], [14, 12], [15, 17], [18, 16], [21, 19], [25, 22], [26, 27], [31, 29], [33, 35], [34, 32], [37, 38], [41, 40], [42, 44], [46, 47], [49, 51]]],

// railing-99_5
//[99.5, 31.5, 0.75, 0.75, 3, 3.375, 26953, -1, 0.0688432, [[1, 2], [5, 4], [7, 9], [11, 10], [12, 15], [16, 14], [19, 17], [20, 22], [25, 23], [28, 30], [29, 26], [34, 31], [36, 35], [40, 38], [41, 42], [43, 46], [48, 45], [52, 49], [54, 53], [57, 55], [60, 63], [62, 60], [65, 68], [70, 69], [73, 72], [74, 76], [76, 79], [81, 78], [84, 82], [85, 87], [89, 88], [93, 90], [95, 98], [96, 94], [100, 101], [104, 106], [107, 108], [110, 111], [112, 115], [116, 113], [118, 119], [120, 122], [124, 125], [128, 126], [129, 130]]],


//// Main deck

// railing-45_5
//[45.5, 31.5, 0.75, 0.75, 3, 3.375, 875152, -1, 0.308062, [[3, 2], [7, 5], [8, 10], [12, 11], [14, 15], [16, 18], [20, 17], [23, 21], [25, 26], [29, 27], [30, 32], [34, 37], [37, 35], [40, 38], [42, 43], [45, 44], [47, 50], [48, 46], [50, 53], [55, 56], [57, 59]]],

// railing-46_25
//[46.25, 31.5, 0.75, 0.75, 3, 3.375, 456778, -1, 0.89872, [[2, 3], [4, 7], [7, 8], [9, 12], [12, 10], [15, 14], [18, 19], [22, 20], [24, 25], [28, 31], [30, 27], [33, 34], [36, 38], [39, 42], [44, 41], [47, 44], [48, 47], [52, 49], [53, 54], [57, 55], [59, 58]]],

// railing-76_5-1
//[76.5, 31.5, 0.75, 0.75, 3, 3.375, 111138, -1, 0.50025, [[3, 1], [4, 5], [7, 6], [10, 12], [12, 9], [14, 15], [19, 18], [21, 23], [26, 24], [27, 30], [30, 27], [31, 32], [35, 34], [37, 39], [41, 40], [43, 46], [45, 43], [48, 51], [52, 53], [54, 56], [57, 60], [61, 59], [65, 62], [67, 66], [69, 72], [70, 68], [74, 73], [75, 77], [79, 80], [84, 81], [86, 84], [88, 91], [90, 87], [92, 94], [94, 97], [99, 98]]],

// railing-76_5-2
//[76.5, 31.5, 0.75, 0.75, 3, 3.375, 7740, -1, 0.473108, [[3, 2], [6, 4], [8, 9], [13, 10], [15, 14], [17, 20], [19, 17], [21, 23], [25, 26], [27, 30], [30, 32], [33, 36], [38, 35], [41, 38], [42, 41], [45, 47], [46, 44], [48, 50], [51, 52], [54, 57], [58, 55], [61, 59], [65, 62], [66, 69], [67, 65], [71, 70], [72, 74], [76, 77], [78, 81], [81, 83], [84, 87], [89, 86], [90, 91], [94, 92], [98, 95], [100, 98]]],

// railing-76_5-3
//[76.5, 31.5, 0.75, 0.75, 3, 3.375, 297750, -1, 0.658313, [[3, 2], [4, 7], [9, 8], [11, 12], [13, 16], [18, 15], [20, 19], [24, 22], [25, 26], [27, 29], [32, 31], [35, 38], [37, 34], [40, 41], [44, 43], [46, 47], [48, 51], [52, 49], [55, 53], [57, 58], [62, 59], [63, 65], [65, 62], [67, 68], [72, 70], [75, 74], [79, 81], [80, 77], [82, 84], [85, 86], [88, 90], [91, 94], [95, 92], [99, 97]]],

// railing-76_5-4
//[76.5, 31.5, 0.75, 0.75, 3, 3.375, 292419, -1, 0.407958, [[3, 2], [7, 4], [8, 9], [12, 11], [13, 16], [17, 19], [21, 18], [24, 23], [27, 30], [29, 26], [30, 33], [33, 34], [35, 38], [40, 39], [44, 47], [45, 42], [47, 50], [51, 52], [54, 56], [57, 55], [60, 57], [61, 62], [65, 64], [68, 66], [70, 71], [75, 72], [77, 80], [78, 76], [81, 83], [85, 84], [86, 88], [89, 91], [92, 90], [95, 94], [99, 97]]],

// railing-59_25
//[59.25, 31.5, 0.75, 0.75, 3, 3.375, 746540, -1, 0.387186, [[2, 3], [7, 5], [10, 9], [11, 14], [16, 13], [19, 18], [21, 23], [25, 24], [29, 27], [30, 31], [33, 36], [35, 32], [37, 38], [42, 40], [44, 45], [47, 49], [51, 48], [54, 52], [55, 56], [59, 57], [60, 62], [65, 66], [69, 72], [70, 68], [72, 74], [76, 75]]],

// railing-59_5
//[59.5, 31.5, 0.75, 0.75, 3, 3.375, 992343, -1, 0.250638, [[1, 2], [3, 6], [7, 9], [9, 12], [14, 11], [17, 14], [18, 19], [22, 20], [23, 24], [27, 26], [28, 30], [31, 34], [34, 31], [37, 35], [40, 39], [43, 41], [45, 44], [48, 51], [50, 47], [52, 54], [54, 57], [59, 58], [61, 62], [65, 64], [66, 68], [68, 71], [72, 69], [75, 73], [77, 76]]],


//// Master deck

// railing-11_75
//[11.75, 31.5, 0.75, 0.75, 3, 3.375, 287589, -1, 0.510862, [[2, 1], [5, 4], [7, 8], [9, 11], [13, 12]]],

// railing-55_25
//[55.25, 31.5, 0.75, 0.75, 3, 3.375, 223904, -1, 0.0060154, [[3, 2], [6, 7], [10, 9], [11, 13], [14, 17], [19, 16], [22, 20], [23, 25], [26, 27], [30, 33], [32, 29], [36, 35], [40, 38], [43, 42], [47, 50], [48, 46], [51, 52], [56, 55], [57, 60], [60, 63], [65, 62], [67, 66], [68, 70]]],

// railing-54_5
//[54.5, 31.5, 0.75, 0.75, 3, 3.375, 320360, -1, 0.763947, [[3, 2], [4, 7], [9, 8], [11, 13], [15, 12], [16, 18], [20, 21], [25, 23], [27, 26], [30, 32], [31, 28], [34, 33], [38, 35], [39, 40], [42, 45], [45, 43], [47, 48], [49, 51], [54, 52], [55, 56], [58, 61], [62, 60], [65, 63], [67, 66], [68, 69]]],

// railing-59_75-1
//[59.75, 31.5, 0.75, 0.75, 3, 3.375, 61400, -1, 0.450297, [[0, 1], [3, 5], [8, 6], [10, 9], [13, 16], [15, 12], [17, 18], [21, 19], [22, 23], [24, 27], [29, 26], [32, 31], [34, 35], [38, 36], [42, 41], [46, 49], [47, 44], [50, 52], [55, 53], [57, 56], [59, 60], [62, 65], [66, 63], [67, 68], [70, 72], [74, 73], [76, 77]]],

// railing-59_75-2
//[59.75, 31.5, 0.75, 0.75, 3, 3.375, 488015, -1, 0.765113, [[2, 0], [4, 5], [9, 7], [12, 11], [15, 18], [16, 13], [19, 21], [24, 23], [25, 27], [29, 30], [31, 34], [34, 37], [38, 36], [42, 39], [45, 44], [46, 47], [50, 48], [53, 56], [54, 51], [57, 59], [60, 61], [62, 64], [64, 67], [68, 66], [71, 69], [75, 74], [76, 77]]],

[]]) if (len(b)>0) b];

module railings(railings, i=0, o=0) {
    if (i < len(railings)) {
        r=balusters_load(railings[i]);
        translate([o, 0, 0]) {
            railing(r,left_post=i==0);
        }
        railings(railings, i+1, o + balusters_hspan(r) + post_width());
    }
}

if (false) {
if (len(railings) == 0) {

    railing=fill_gaps(balusters_new(horizontal_span,vertical_span(),initial_seed=initial_seed));
    echo(str(balusters_dump(railing)));

} else if (len(railings) == 1) {

    railing = balusters_load(railings[0]);

    balusters_report(railing);

//    instructions(railing);

//    rotate([0,0,-90]) {
//        translate([0, -feet(2), inches(12)]) {
            railing(railing, show_gaps=false);
//        }
//    }

} else {
    railings(railings);
}
}
