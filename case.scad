// Typically the ID on JLC SLM prints seems to be ~0.37mm undersized

$fn = 100;

bottom_thickness = 1.5;

module usb_port(depth=9.3) {
    width = 8.94 + 0.5;
    height = 3.02 + 0.6;
    color("#bbb") linear_extrude(depth) {
        translate([-(width - height / 2) / 2, 0, 0]) {
            translate([0, height / 4, 0]) circle(d=height/2);
            translate([0, -height / 4, 0]) circle(d=height/2);
        }
        square([width - height / 2, height], center = true);
        square([width, height / 2], center = true);
        translate([(width - height / 2) / 2, 0, 0]) {
            translate([0, height / 4, 0]) circle(d=height/2);
            translate([0, -height / 4, 0]) circle(d=height/2);
        }
    }
    color("black") linear_extrude(3.11) {
        square([10, 4.61], center = true);
    }
}

module upstream_port(depth=7.35) {
    width = 8.94 + 0.6;
    height = 3.16 + 0.2;
    color("#bbb") translate([-width/2, -4.84 - (depth - 7.35), 0]) {
        translate([height/4, 0, height/4]) {
            translate([0, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
            translate([width - height / 2, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
            translate([0, 0, height - height/2]) {
                translate([0, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
                translate([width - height / 2, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
            }
        }
        translate([0, 0, height/4]) cube([width, depth, height - height/2]);
        translate([height/4, 0, 0]) cube([width - height/2, depth, height]);
    }
}

module led(depth = 9.3) {
    cylinder(depth, d=3 + 0.1);
    cylinder(depth - 4.2 - (depth - 9.3), d=4 + 0.1);
}

module port_with_led(depth=9.3) {
    usb_port(depth);
    translate([-9.2, 0, 0]) color("red") led(depth);
}

module inductor() {
    color("#777") linear_extrude(3) {
        square([7.1 + 0.2, 6.6 + 0.2], center = true);
    }
}

module capacitor() {
    color("black") linear_extrude(2) {
        square(6.6, center = true);
    }
    color("#ccccff") cylinder(7.7 + 0.5, d=6.3 + 0.7);
}

module port_row(depth=9.3) {
    translate([42.1, -6.26, 0]) inductor();
    translate([-3.35, -7.8, 0]) capacitor();
    translate([7.2, -5.7, 0]) capacitor();
    translate([28.15, -2.1, 0]) capacitor();
    translate([54.7, -6.1, 0]) capacitor();
    translate([67.9, -7.8, 0]) capacitor();
    for ( x = [ 0 : 3 ]) {
        dx = 20 * x;
        translate([dx, 0, 0]) {
            if (x <= 1) {
                port_with_led(depth);
            } else {
                rotate([0, 0, 180]) port_with_led(depth);
            }
        }
    }
}

module pcb() {
    difference() {
        color("green") translate([-0.3, - 0.3, 0]) cube([84 + 0.6, 81 + 0.6, 1.6 + 0.1]); // PCB base material
        translate([29.6, 39.45, 0]) cylinder(h=1.6, d=3.2 - 0.7); // Alignment hole
    };
    translate([0, 0, 1.6]) {
        translate([0.5, 0.5, 0]) cube([84 - 1, 81 - 1, 2]); // Various components
        translate([39.2, 2.65, 0]) linear_extrude(3) square([7, 3.4], center = true); // TVS
        translate([30.68, 3.59, 0]) upstream_port();
        translate([12, 13.75, 0]) {
            for (y = [ 0 : 4 ]) {
                dy = 16 * y;
                translate([0, dy, 0]) port_row();
            }
        }
    }
    translate([0, 0, -1]) { // Bottom clearance
        difference() {
            translate([0.5, 0.5, 0]) cube([84 - 1, 81 - 1, 1]); // Various components
            translate([29.6, 39.45, 0]) cylinder(h=1, d=3.2);
        }
    }
}

module pcb_for_shell() {
    pcb();
    translate([0, 0, 1.6]) {
        translate([30.68, 3.59, 0]) upstream_port(10);
        translate([12, 13.75, 0]) {
            for (y = [ 0 : 4 ]) {
                dy = 16 * y;
                translate([0, dy, 0]) port_row(10);
            }
        }
    }
}

module pcb_for_bottom_shell() {
    pcb_for_shell();
    translate([-0.1, - 0.3, 1.6 + 0.3]) cube([84 + 0.6, 81 + 0.6, 5]); // Ensure no overlap over PCB
    translate([-1, -1, 1.6 + 0.1]) cube([84 + 2, 81 + 2, 5]); // Ensure no overlap over PCB
}

module pcb_for_top_shell() {
    pcb_for_shell();
    translate([0.5, 0.5, -1]) cube([84 - 1, 81 - 1, 3]); // Various components
    translate([0, 0, 1.6]) {
        translate([30.68, 3.59, 0]) color("#bbb") translate([-8.94/2, -4.84 - (10 - 7.35), 0]) cube([8.94, 10, 2]);
    }
}

module rounded_rect(x, y, z, r) {
    translate([r, r, 0]) {
        cylinder(z, r=r);
        translate([x - r * 2, 0, 0]) cylinder(z, r=r);
        translate([0, y - r * 2]) {
            cylinder(z, r=r);
            translate([x - r * 2, 0, 0]) cylinder(z, r=r);
        }
    }
    translate([r, 0, 0]) cube([x - r*2, y, z]);
    translate([0, r, 0]) cube([x, y - r*2, z]);
}

module hexagon(h, r) {
    translate([0, 0, h/2]) cylinder(h, r=r, center=true, $fn=6);
}

module hex_nut() {
    hexagon(2.35 + 0.5, 3.1 + 0.3);
}

module hex_screw() {
    translate([0, 0, 12]) cylinder(3.1, d=5.5 + 0.2);
    cylinder(12, d=3.2 + 0.2);
}

module hex_screw_nut() {
    color("#ccc") {
        hex_screw();
        hex_nut();
    }
}

module features() {
    translate([4.5, 4.5, 0]) rotate([0, 0, 30]) hex_screw_nut();
    translate([100 - 4.5, 4.5, 0]) rotate([0, 0, 30]) hex_screw_nut();
    translate([0, 91 - 4.5, 0]) {
        translate([4.5, 0, 0]) rotate([0, 0, 30]) hex_screw_nut();
        translate([100 - 4.5, 0, 0]) rotate([0, 0, 30]) hex_screw_nut();
    }
}

module cutouts() {
        translate([0, 0, bottom_thickness]) {
                translate([1.5, 9, 0]) cube([4.5, 73, 11]);
                translate([100 - 4.5 - 1.5, 9, 0]) cube([4.5, 73, 11]);
                translate([9, 91 - 4.5 - 1.5, 0]) cube([81, 4.5, 11]);
        }
        translate([0, 0, bottom_thickness + 1 + 1.6]) {
                translate([1.5 + 4.5, 9, 0]) cube([4.5, 73, 11]);
                translate([100 - 3 - 1.5 - 4.5, 9, 0]) cube([4.5, 73, 11]);
                translate([9, 91 - 3 - 1.5 - 4.5, 0]) cube([81, 4.5, 11]);
        }
}

module bottom_shell() {
    difference() {
        color("#ddd") rounded_rect(100, 91, bottom_thickness + 1 + 1.6 + 3.16 / 2, 5);
        union() {
            features();
            translate([8, 2, bottom_thickness + 1]) pcb_for_bottom_shell();
            cutouts();
        }
    }
}

module top_shell() {
    difference() {
        translate([-100 / 2, -91 / 2, 0]) color("#ddd") translate([0, 0, 2]) intersection() { cube([200, 200, 15 - 2 - 6 + 200]); rounded_rect(100, 91, 15 - 2, 5); }
        union() {
            translate([-100 / 2, -91 / 2, 0]) union() {
                features();
                //scale([0.99, 0.99, 1]) bottom_shell();
                bottom_shell();
                translate([8, 2, 4]) pcb_for_top_shell();
                //translate([8, 2, 4]) scale([1.01, 1.01, 1.01]) pcb_for_top_shell();
                cutouts();
                translate([8 + 1, 2 + 1, 4]) {
                    difference() {
                        cube([84 - 2, 81 - 2, 9]);
                        translate([20, 0, 0]) cube([20, 10, 30]);
                    }
                }
            }
            scale([0.99, 0.99, 1]) translate([-100 / 2, -91 / 2, 0]) bottom_shell();
            //translate([8, 2, 4]) scale([1.01, 1.01, 1.01]) translate([-100 / 2, -91 / 2, 0]) pcb_for_top_shell();
        }
    }
}

//rounded_rect(100, 100, 10, 5);
bottom_shell();
//rotate([180, 0, 0]) top_shell();
//rotate([180, 0, 0]) intersection() { top_shell(); translate([8, 2, 4 + 9]) cube([84, 81, 9]); }

//translate([8, 2, 4]) pcb();
//features();
