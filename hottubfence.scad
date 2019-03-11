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

function slat_thickness() = inches(1.5);
function slat_width() = inches(3.5);
function slat_skew() = inches(1.25);
function slat_gap() = inches(1);
function walnut() = [0.247, 0.165, 0.078];

function target_height() = feet(6);
function slat_count() = ceil(target_height()/slat_offset());
function slat_offset() = slat_gap()+slat_width()-slat_skew();
function height() = slat_count()*slat_offset();

module slat(length) {
    thickness = slat_thickness();
    width = slat_width();
    skew = slat_skew();
    face_height = width-skew;
    color(walnut())
    rotate([90,0,90])
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
    translate([-slat_thickness(),0,0]) {
        fence(feet(10)+slat_thickness());
    }
    translate([0,0,-inches(1)]) {
        linear_extrude(height()+inches(2)) {
            polygon([[-slat_thickness()-inches(1),slat_thickness()+inches(1)],
                    [slat_thickness()+inches(1),-slat_thickness()-inches(1)],
                    [-slat_thickness()-inches(1),-slat_thickness()-inches(1)]]);
        }
    }
}

difference() {
    translate([0,-feet(5),0]) {
        rotate([0,0,90]) {
            fence(feet(5)+slat_thickness());
        }
    }
    translate([0,0,-inches(1)]) {
        linear_extrude(height()+inches(2)) {
            polygon([[-slat_thickness()-inches(1),slat_thickness()+inches(1)],
                    [slat_thickness()+inches(1),-slat_thickness()-inches(1)],
                    [slat_thickness()+inches(1),slat_thickness()+inches(1)]]);
        }
    }
}

translate([0,-inches(3.5),0]) {
    color(walnut())
    cube([inches(3.5), inches(3.5), height()]);
}

translate([0,-feet(5),0]) {
    color(walnut())
    cube([inches(3.5), inches(3.5), height()]);
}

echo(height_feet=(height())/feet(1));
