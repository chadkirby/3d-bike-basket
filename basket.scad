$fs = 1;
$fa = 6;

rackTubeD = 9.7;
rackOD = [9.25 * 25.4 - rackTubeD, 12.0625 * 25.4 - rackTubeD];
basketOD = [11.875 * 25.4, 14 * 25.4, 50];
boxWall = 3.5;
boxFloatZ = 50;
supportThick = 4;
module rackRod(l, inflate=0) {
    cylinder(d=rackTubeD+inflate, h=l, center=true);
}
module rackRodShort(l=rackOD[0], inflate=0) {
    rotate([0, 90, 0]) rackRod(l, inflate);
}
module rackRodLong(inflate=0) {
    rotate([90, 0, 0]) rackRod(rackOD[1], inflate);
}
module moveRackRight() {
    translate([0, rackOD[1]/2]) children();
}
module moveRackLeft() {
    translate([0, -rackOD[1]/2]) children();
}
module moveBoxRight() {
    translate([0, basketOD[1]/2]) children();
}
module moveBoxLeft() {
    translate([0, -basketOD[1]/2]) children();
}
module rack(inflate = 0) {
    moveRackRight() rackRodShort(inflate=inflate);
    moveRackLeft() rackRodShort(inflate=inflate);
    translate([rackOD[0]/2, 0]) rackRodLong(inflate=inflate);
    translate([-rackOD[0]/2, 0]) rackRodLong(inflate=inflate);
    translate([-rackOD[0]/2 - 25.4/2 - rackTubeD/2, 0]) {
        translate([0, 1.125 * 25.4 - rackTubeD/2]) rotate([0, 90, 0]) rackRod(25.4, inflate);
        translate([0, -(1.125 * 25.4 - rackTubeD/2)]) rotate([0, 90, 0]) rackRod(25.4, inflate);
        translate([-25.4/2, 0, 50]) {
            translate([0, 1.125 * 25.4 - rackTubeD/2]) rackRod(100, inflate);
            translate([0, -(1.125 * 25.4 - rackTubeD/2)]) rackRod(100, inflate);
        }
    }

}
module box(inflate=0) {
    translate([0,0,25 + boxFloatZ]) difference() {
        cube(size=basketOD, center=true);
        cube(size=[basketOD[0] - boxWall - inflate, basketOD[1] - boxWall - inflate, 51], center=true);
    }
}
module support() {
    supportD = rackTubeD + supportThick*2;
    wide = 15;
    difference() {
        union() {
            translate([0,2,1]) {
                moveRackLeft() rotate([0, 90]) cylinder(d=rackTubeD + supportThick*2 + 5, h=wide, center=true);
            }
            hull() {
                moveRackLeft() rotate([0, 90]) cylinder(d=rackTubeD + supportThick*2, h=wide, center=true);
                translate([0,supportD/2,boxFloatZ]) moveBoxLeft() rotate([0, 90]) cylinder(d=supportD, h=wide, center=true);
            }
            hull() {
                translate([0,supportD/2,boxFloatZ]) moveBoxLeft() rotate([0, 90]) cylinder(d=supportD, h=wide, center=true);
                translate([0,supportD/4,boxFloatZ + basketOD[2] - supportD/4]) moveBoxLeft() rotate([0, 90]) cylinder(d=supportD/2, h=wide, center=true);
            }
        }
        box();
        rack(0.5);
        // screws to affix the basket
        translate([0,0,boxFloatZ + basketOD[2]/4]) moveBoxLeft() rotate([90,0,0]) cylinder(d=4, h=100, center=true);
        translate([0,0,boxFloatZ + 3 * basketOD[2]/4]) moveBoxLeft() rotate([90,0,0]) cylinder(d=4, h=100, center=true);

        moveRackLeft() rotate([-40]) {
            hull() {
                rackRodShort(25, inflate=-4);
                translate([0,0,15]) rackRodShort(25, inflate=2);
            }
            translate([0,30,0]) rotate([75]) {
                cylinder(d=4, h=100, center=true);
                rotate([0,180,0]) translate([0,0,-22])  cylinder(d=9, h=100, center=false);
                rotate([0,180,0]) translate([0,0,-25])  cylinder(d=5, h=100, center=false);
            }
        }

    }
}


module screw(headD, nutFlat = 0, throughHoleD, threadD, throughLen = 0, threadLen = 0, headLen, nutLen) {
    // head
    translate([0, 0, -headLen]) cylinder(d=headD, h=headLen, center=false);
    // through hole
    cylinder(d=throughHoleD, h=throughLen, center=false);
    // through
    /*translate([0, 0, -throughLen]) cylinder(d=threadD, h=threadLen, center=false);*/
    translate([0, 0, throughLen])
        if (nutFlat > 0) {
            // nut
            cylinder(d=nutFlat/cos(180/6), h=nutLen, center=false, $fn=6);
        } else {
            // thread
            cylinder(d=threadD, h=threadLen, center=false);
        }
}
module m4PanHeadScrew(length = 20) {
    translate([-length/2, 0, 0]) rotate([0, 90, 0]) screw(
        headD = 9.3,
        headLen = 100,
        nutFlat = 7.25,
        throughHoleD = 5,
        nutLen = 100,
        throughLen = length
    );
}
!support();
rotate([0,0,180]) support();
translate([-(basketOD[1] - basketOD[0])/2,0,0]) rotate([0,0,90]) support();
#box();
