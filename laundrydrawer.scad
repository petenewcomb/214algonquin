function width() = 17.25;
function interior_height() = 22;
function height() = interior_height() + 2;
function interior_depth() = 24;

function walnut() = [0.247, 0.165, 0.078];
function lightwalnut() = [0.397, 0.315, 0.228];
function maple() = "tan";

$fa = 1;
$fs = 0.125;

union() {
  translate([0, 0, 0]) {
    color(lightwalnut()) cube([width(), 0.75, height()]);
  }
  translate([0, interior_depth() + 0.75, 2]) {
    difference() {
      color(maple()) cube([width(), 0.75, interior_height()]);
      translate([2 + 1, -0.25, height() + 1 - 10]) {
        color(maple()) minkowski() {
          rotate([-90,0,0]) {
            cylinder(d=2, h=1.25);
          }
          cube([width() - 6, 1.25, 4]);
        }
      }
    }
  }
  translate([0, 0.75, 2 - 0.75]) {
    color(maple()) cube([width(), interior_depth() + 0.75, 0.75]);
  }
  translate([0, 0.75, 0.25]) {
    color(maple()) cube([0.75, interior_depth()+0.75, 1]);
  }
  translate([width()-0.75, 0.75, 0.25]) {
    color(maple()) cube([0.75, interior_depth()+0.75, 1]);
  }
  translate([0.25, 0.75, height() - 1.75]) {
    color(maple()) cube([width()-0.5, 0.75, 1.5]);
  }
  translate([1, 0.25, height() - 1]) {
    rotate([-90, 0, 0]) {
      color("silver") cylinder(d = 0.5, h = interior_depth() + 1);
    }
  }
  translate([width() - 1, 0.25, height() - 1]) {
    rotate([-90, 0, 0]) {
      color("silver") cylinder(d = 0.375, h = interior_depth() + 1);
    }
  }
  translate([0, interior_depth() + 0.75, 2]) {
    rotate([90, 0, 90]) {
      color(maple()) linear_extrude(0.75) {
        polygon([[0, 0], [3-interior_depth()/2, 0], [0, interior_height() - 8]]);
      }
    }
  }
  translate([width() - 0.75, interior_depth() + 0.75, 2]) {
    rotate([90, 0, 90]) {
      color(maple()) linear_extrude(0.75) {
        color(maple()) polygon([[0, 0], [3-interior_depth()/2, 0], [0, interior_height() - 8]]);
      }
    }
  }
}
