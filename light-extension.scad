$fs = 1;
$fa = 6;

module ry(ii = 1) {
    rotate([ii * 90,0]) children();
}
module rx(ii = 1) {
    rotate([0,ii * 90]) children();
}

module moveBack(dims = [0, 0]) {
    translate([0 + dims[0], -100 + dims[1]]) children();
}
module connector(inflate = 0) {
    translate([5,-22])
    hull() {
        rx() cylinder(d=4 + inflate, h=4, center=false);
        translate([0,-55])
        rx() cylinder(d=5 + inflate, h=4, center=false);
    }
}

module lightClip() {
    difference() {
        hull() {
            rx() cylinder(d=15, h=17, center=true);

            moveBack() rx() cylinder(d=18, h=17, center=true);
        }
        rx() cylinder(d=6, h=100, center=true);

        hull() {
            translate([0, 10])
            cylinder(d=11, h=25, center=true);

            translate([0, -15])
            cylinder(d=11, h=25, center=true);
        }

        moveBack([5, 0]) rx() cylinder(d=12, h=17, center=true);
        moveBack() rx() cylinder(d=6, h=20, center=true);

        for (dd=[30:10:50]) {
            translate([0, -dd]) cylinder(d=3.5, h=50, center=true);
        }


        *translate([0,0,7.5])
        rotate([-3.5, 0]) {
            scale([1.25, 1, 1])
            ry() cylinder(d=9, h=100, center=false);
        }
        *translate([0,0,-7.5])
        rotate([3.5, 0]) {
            scale([1.25, 1, 1])
            ry() cylinder(d=9, h=100, center=false);
        }
    }
}
module selector() {
    translate([-3, 0])
    cube(size=[17, 300, 25], center=true);
}
module piece0() {
    translate([-10, 0])
    rotate([0, -90]) {
        intersection() {
            lightClip();

            translate([-0.1, 0]) selector();
        }
        connector();
    }
}
module piece1() {
    translate([10, 0])
    rotate([0, 90]) {
        difference() {
            lightClip();
            selector();
            connector(0.75);
        }
    }
}

piece0();
piece1();
