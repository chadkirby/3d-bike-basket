use <basket.scad>

module taper(d, h, dir) {
    taperH = (h - 35) / 2;
    hull() {
        cylinder(d=d, h=35, center=true);

        translate([dir[0] * -d/4, dir[1] * -d/4])
        cylinder(d=d/2, h=h, center=true);
    }
}

module center(d, height) {
    taper(d=5, h=height, dir=[1, 1]);
}

module base(height = 40) {
    difference() {
        translate([2.5, 2.5]) {
            hull() {
                center(5, height);
                translate([12.5, 0])
                    taper(d=5, h=height, dir=[0, 1]);
            }
            hull() {
                center(5, height);
                translate([0, 12.5])
                    taper(d=5, h=height, dir=[1, 0]);
            };
            hull() {
                center(5, height);
                translate([0, 6])
                    taper(d=5, h=height, dir=[1, 0]);
                    translate([6, 0])
                        taper(d=5, h=height, dir=[1, 0]);
            };
        }

        cylinder(d=10, $fn=4, h=100, center=true);
    }
}
module screwAssembly(d = 3.5) {
    translate([12, 0, 25.4/2])
        screw(d);

    translate([12, 0, -25.4/2])
        screw(d);
}
module moveToInside() {
    translate([3.5, 3.5]) children();
}
module reinforcement() {
    moveToInside()
    difference() {
        base();

        screwAssembly();
        rotate([0,0,90])
            screwAssembly();
    }
}

module drillGuide(args) {
    difference() {
        translate([8, 8, 5])
            cube(size=[25, 25, 45], center=true);
        translate([2.25, 12.5])
            cube(size=[4.5, 25, 51], center=true);
        translate([12.5, 2.25])
            cube(size=[25, 4.5, 51], center=true);

        translate([12.5, 12.5, -5])
            cube(size=[25, 25, 51], center=true);

        moveToInside() {
            screwAssembly(4.5);
            rotate([0,0,90])
                screwAssembly(4.5);
            translate([2, 2, -50])
            cube(size=[20, 20, 100], center=false);
        }
        translate([0,0,-24.5])
        hull() {
            cube(size=[5, 5, 100], center=true);
            translate([10,10])
            cube(size=[5, 5, 100], center=true);
        }
    }
}

reinforcement();

!rotate([0, 180])
drillGuide();
