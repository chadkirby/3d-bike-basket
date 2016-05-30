$fs = 1;
$fa = 6;

width = 17.5;
len = 95;

module ry(ii = 1) {
    rotate([ii * 90,0]) children();
}
module rx(ii = 1) {
    rotate([0,ii * 90]) children();
}
module mz(zz) {
    translate([0, 0, zz]) children();
}
module mx(xx) {
    translate([xx, 0]) children();
}
module my(yy) {
    translate([0, yy]) children();
}

module moveBack(dims = [0, 0, 0]) {
    translate([0 + dims[0], -95 + dims[1], dims[2] ? dims[2] : 0]) children();
}
module moveMid() {
    translate([0, -35, -15]) children();
}
module connector(inflate = 0) {
    difference() {
        translate([4, 0]) hull() {
            moveMid() rx() cylinder(d=4 + inflate, h=5, center=false);

            moveBack()
            translate([0, 0.25 * 50, 0.25 * -15])
            rx() cylinder(d=5 + inflate, h=5, center=false);
        }
        rackMount();
    }
}

module rackMount() {
    // hole to fit around the rack light mount
    moveBack([12, 0]) rx() cylinder(d=12, h=width, center=true);
    // screw hole to mount to the rack
    moveBack() rx() cylinder(d=6.5, h=25, center=true);

}
module lightClip() {
    difference() {
        union() {
            hull() {
                rx() cylinder(d=15, h=width, center=true);
                moveMid() rx() cylinder(d=16, h=width, center=true);
            }
            hull() {
                moveMid() rx() cylinder(d=16, h=width, center=true);
                moveBack() rx() cylinder(d=18, h=width, center=true);
            }
            translate([0, -len/2, -5]) rotate([0,0,180/6]) cylinder(d=width/cos(180/6), $fn=6, h=10, center=true);
        }

        // screw hold for z support
        translate([0, -len/2]) cylinder(d=3.5, h=50, center=true);

        // thru-hole to clamp the light in place
        rx() cylinder(d=6.5, h=100, center=true);

        translate([-1, -43, 26]) rotate([-10,0, 0]) scale([1, 1.15, 1]) rx() rotate_extrude() translate([41,0]) circle(d=8);


        // cutout for the light flange
        rotate([1/tan(35/15),0,0])
        hull() {
            translate([0, 10])
            cylinder(d=11, h=25, center=true);

            translate([0, -15])
            cylinder(d=11, h=25, center=true);
        }

        rackMount();

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
    translate([-3.25, 0])
    cube(size=[width, 300, 100], center=true);
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
    translate([20, 0, -width + 3.25])
    rotate([0, -90, 0]) {
        difference() {
            lightClip();
            selector();
            connector(0.75);
        }
    }
}
module supportBase(h = 10) {
    cylinder(d=width, $fn=6, h=h, center=false);
}
module moveToHook() {
    translate([-28, 0, 65]) children();
}
hookH = width * cos(180/6);
module supportHook() {
    moveToHook()
    ry() cylinder(d=15.5, h=hookH, center=true);
}
module lightSupport() {
    difference() {
        hull() {
            supportBase(5);
            supportHook();
        }
        cylinder(d=5, h=100, center=true);
        mz(5)
        cylinder(d1=10, d2=20, h=50, center=false);


        moveToHook()
        ry() {
            cylinder(d=10.5, h=hookH + 1, center=true);
            hull() {
                cylinder(d=5, h=hookH + 1, center=true);

                translate([-30, -60, 0])
                cylinder(d=100, h=hookH+1, center=true);
            }
        }

    }
}
*lightClip();
piece0();
piece1();
*my(-len/2)
ry()
lightSupport();
