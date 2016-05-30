$fs = 1;
$fa = 6;

rackTubeD = 9.7;
rackOD = [
    9.25 * 25.4 - rackTubeD,
    (12 + 1/32) * 25.4 - rackTubeD
];
basketOD = [
    (11 + 15/16) * 25.4,
    14 * 25.4,
    51.5
];
boxWall = 3.5;
// distance from center of rack tube to outer box wall
basketDelta = [
    (basketOD[0] - rackOD[0])/2,
    (basketOD[1] - rackOD[1])/2
];
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
module moveRackLeft() {
    translate([0, -rackOD[1]/2]) children();
}
module moveRackRight() {
    rotate([0,0,180]) moveRackLeft() children();
}
module moveRackFront() {
    translate([0, -rackOD[0]/2]) children();
}
module moveBoxLeft(dist = 1) {
    translate([0, -dist * basketDelta[1]]) moveRackLeft() children();
}
module moveBoxFront(dist = 1) {
    translate([0, -dist * basketDelta[0]]) moveRackLeft() children();
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
    translate([
        0,
        0,
        25 + boxFloatZ
    ]) difference() {
        cube(size=basketOD, center=true);
        cube(size=[
            basketOD[0] - 2*boxWall - inflate,
            basketOD[1] - 2*boxWall - inflate,
            basketOD[2] + 1
        ], center=true);
    }
}
module moveUpArm0(dist = 1) {
    translate([0, dist * midSupportD/2, dist * boxFloatZ]) moveBoxLeft(dist) children();
}
module moveUpArm(dist = 1, direction = 0) {
    rr = direction == 1 ? basketDelta[0] - 5.5 : basketDelta[1] - 5.5;
    straightDist = (boxFloatZ - rr);
    xyz = dist > 0.25 ? [
        0, -rr, rr + (dist - 0.25)/0.75 * straightDist
    ] : [
        0, rr * cos(-90 - dist * 360), rr + rr * sin(-90 - dist * 360)
    ];
    translate(xyz) {
        if (direction == 0) {
            moveBoxLeft(0) children();
        } else {
            moveBoxFront(0) children();
        }
    }
}

supportD = rackTubeD + supportThick*2;
midSupportD = supportD * 0.625;
wide = 15;
module basketScrews(d=3.5) {
    translate([
        0,
        0,
        boxFloatZ + (basketOD[2] - 25.4)/2
    ]) moveBoxLeft() screw(d);
    translate([
        0,
        0,
        boxFloatZ +(basketOD[2] - 25.4)/2 + 25.4 // screw holes 1" apart
    ]) moveBoxLeft() screw(d);
}
module screw(d=3.5) {
    rotate([90,0,0]) cylinder(d=d, h=100, center=true);
}
module support(direction = 0) {
    difference() {
        union() {
            for (dd=[0.0:0.05:0.25]) {
                hull() {
                    moveUpArm(direction = direction, dist = dd)
                        rotate([0, 90]) cylinder(d=supportD - (dd*2 * (supportD - midSupportD)), h=wide, center=true);
                    moveUpArm(direction = direction, dist = dd + 0.05)
                        rotate([0, 90]) cylinder(d=supportD - ((dd*2 + 0.05) * (supportD - midSupportD)), h=wide, center=true);
                }
            }
            hull() {
                moveUpArm(direction = direction, dist = 0.25)
                    rotate([0, 90]) cylinder(d=supportD - (0.5 * (supportD - midSupportD)), h=wide, center=true);

                moveUpArm(direction = direction, dist = 1)
                    rotate([0, 90]) cylinder(d=midSupportD, h=wide, center=true);

            }

            hull() {
                moveUpArm(direction = direction, dist = 1) rotate([0, 90]) cylinder(d=midSupportD, h=wide, center=true);
                translate([0, -1, basketOD[2] - supportD/4 - 5]) moveUpArm(direction = direction, dist = 1) rotate([0, 90]) cylinder(d=supportD/2, h=wide, center=true);
            }
        }
        if (direction == 0) {
            box();
            scale([1.02, 1.02, 1]) box();
        } else {
            translate([0, (basketDelta[1] - basketDelta[0]),0]) {
                box();
                scale([1.02, 1.02, 1]) box();
            }
        }
        rack(0.25);
        // screws to affix the basket
        basketScrews();

        // clip around the rack tube
        moveRackLeft() moveRackLeft() rotate([180]) {
            hull() {
                moveUpArm(direction = direction, dist = 0) rackRodShort(25, inflate=-6);
                translate([0,-10,0])
                moveUpArm(direction = direction, dist = 0) rackRodShort(25, inflate=-3);
            }
        }
        // gap that the screw will bridge
        for (dd=[0.0:0.05:0.25]) {
            hull() {
                moveUpArm(direction = direction, dist = dd)
                    rackRodShort(25, inflate=2 - rackTubeD);
                moveUpArm(direction = direction, dist = dd + 0.05)
                    rackRodShort(25, inflate=2 - rackTubeD);
            }
        }

        // screw to clamp support to rack tube
        moveUpArm(direction = direction, dist = 0.08) {
            rotate([
                -360 * 0.08,
                0,
                0
            ]) {
                translate([0, 0, -3]) rotate([-180]) {
                    // thread hole
                    translate([0,0,-12.75]) cylinder(d=3.5, h=102.75, center=false);
                    // through hole
                    translate([0,0,-4]) cylinder(d=5, h=4, center=false);
                    // m4 screw head
                    cylinder(d=8.5, h=10, center=false);

                }
                // m4 nut
                *translate([0,0,supportD/2 - 4]) cylinder(d=8.25/cos(180/6), $fn=6, h=10, center=false);


            }
        }
        // zip-tie
        *zipTieCutout();
        // bungee-hook cutout
        bungeeHookCutout(direction);

    }
}
module zipTieCutout() {
    moveRackLeft() {
        rotate([0, 90]) difference() {
            cylinder(d=supportD + 0.1, h=6, center=true);
            cylinder(d=supportD - 4, h=7, center=true);

        }
    }
}
module bungeeHookCutout(direction) {
    hull() {
        moveUpArm(direction = direction, dist = 0.25) rotate([0, 90]) cylinder(d=rackTubeD - 3, h=wide+1, center=true);
        moveUpArm(direction = direction, dist = 0.5) rotate([0, 90]) cylinder(d=rackTubeD - 4, h=wide+1, center=true);

    }
}
module screwGuide() {
    difference() {
        moveBoxLeft() hull() {
            translate([-10,0,boxFloatZ - 2]) {
                cube(size=[20, 5, basketOD[2] + 4], center=false);
                translate([-20, 5, basketOD[2]/2]) rotate([90]) cylinder(d=30, h=5, center=false);
            }
        }
        #basketScrews();
        #box();
    }
}


*for (yy=[0:25:75]) {
    translate([yy,150 + yy,0])
    rotate([0,90])
    support(0);
}

*rotate([-90]) screwGuide();

*translate([-(basketOD[1] - basketOD[0])/2,0,0]) rotate([0,0,90]) support();
//rotate([0,90])
!support(1);
*translate([rackOD[0]/2, 0, 0]) rotate([0,0,-90]) moveRackLeft() rotate([0,0,180]) support(1);
rotate([0,0,180]) translate([rackOD[0]/2, 0, 0]) rotate([0,0,-90]) moveRackLeft() rotate([0,0,180]) support(1);
%box();
%rack();
