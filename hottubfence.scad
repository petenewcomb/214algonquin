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

//function slat_thickness() = inches(1.5);
function slat_thickness() = inches(.75);
function slat_width() = inches(5.5);
function slat_skew() = inches(0);
function post_width() = inches(3.5);
function post_thickness() = inches(1.5);
function slat_angle() = asin((post_width()-slat_thickness())/slat_width());
function slat_height() = slat_width()*cos(slat_angle());
function slat_gap() = -inches(0);
function walnut() = [0.247, 0.165, 0.078];

function target_height() = feet(6);
function slat_count() = ceil(target_height()/slat_offset());
function slat_offset() = slat_gap()+slat_height()-slat_skew();
function height() = slat_count()*slat_offset();

module slat(length) {
    thickness = slat_thickness();
    width = slat_width();
    skew = slat_skew();
    face_height = width-skew;
    color(walnut())
    rotate([90,slat_angle(),90])
    linear_extrude(length) {
        polygon([[0, 0],
                 [0, face_height],
                 [thickness, width],
                 [thickness, skew]]);
    }
}

module fence(length) {
    for (i=[0:slat_count()-1]) {
        translate([0,0,slat_gap()+i*slat_offset()]) {
            slat(length);
        }
    }
}

difference() {
    offset = post_width();
    translate([-offset,0,0]) {
        fence(feet(10)+offset);
    }
    translate([-feet(1),post_width()-inches(.75),0]) {
        color(walnut()) cube([feet(12),inches(3),feet(7)]);
    }
    translate([0,0,-inches(1)]) {
        linear_extrude(height()+inches(2)) {
            polygon([[-offset-inches(1),offset+inches(1)],
                    [offset+inches(1),-offset-inches(1)],
                    [-offset-inches(1),-offset-inches(1)]]);
        }
    }
}

difference() {
    offset = post_width();
    translate([0,-feet(5),0]) {
        rotate([0,0,90]) {
            fence(feet(5)+offset);
        }
    }
    translate([0,0,-inches(1)]) {
        linear_extrude(height()+inches(2)) {
            polygon([[-offset-inches(1),offset+inches(1)],
                    [offset+inches(1),-offset-inches(1)],
                    [offset+inches(1),offset+inches(1)]]);
        }
    }
}

translate([inches(12),-post_width()+inches(1),0]) {
    color(walnut())
    cube([post_thickness(), post_width(), height()]);
}


*translate([-post_width(),0,0]) {
    color(walnut())
    cube([post_width(), post_width(), height()]);
}

*translate([-post_width(),-feet(5),0]) {
    color(walnut())
    cube([post_width(), post_width(), height()]);
}

echo(height_feet=(height())/feet(1));
