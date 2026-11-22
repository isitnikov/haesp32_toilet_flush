// MG90S toilet-tank rim clip. Dimensions in mm.
// The black-box side (positive X) faces into the tank.
// Z = 0 is the highest point of the bare ceramic rim.
// F6, then File > Export > Export as STL.

/* [Print] */
part = "bracket"; // [bracket:Complete bracket,fit_check:Clip only]

// Measure the widest part of the ceramic rim over the depth of the clip.
rim_thickness = 10;
rim_clearance = 0.8;
// Available vertical space above the rim under the lid.
bridge_thickness = 2;
// Upper cable recess. Check it against the actual wire bundle.
cable_width = 5;
cable_recess_depth = 1.2;

/* [Servo mount] */
// Distance from the rim to the center of the servo mounting face.
servo_drop = 18;
servo_body_length = 22.5;
servo_body_width = 12;
servo_body_clearance = 0.7;
// Measure center to center on your MG90S mounting ears.
screw_pitch = 27.5;
screw_diameter = 2.2;
// Internal depth behind the mounting face, including wire bend space.
pocket_depth = 26;

/* [Hidden] */
eps = 0.02;
clip_width = 40;
leg_wall = 3;
outside_drop = 10;
box_height = 22;
box_width = 36;
box_wall = 2.5;
face_thickness = 4;
inside_drop = servo_drop + box_height / 2;
rim_gap = rim_thickness + rim_clearance;
box_bottom = -inside_drop;
box_left = rim_gap + leg_wall - eps;
mount_x = box_left + pocket_depth;
cable_y = clip_width / 2 - cable_width - 2;
opening_length = servo_body_length + servo_body_clearance;
opening_width = servo_body_width + servo_body_clearance;

assert(bridge_thickness - cable_recess_depth >= 0.8,
       "Leave at least 0.8 mm of material below the cable recess.");
assert(servo_drop - box_height / 2 >= 3,
       "Keep the servo pocket below the rim.");
assert(screw_pitch - screw_diameter > opening_length &&
       screw_pitch + screw_diameter < box_width,
       "Check the servo opening and mounting hole dimensions.");

module rim_clip() {
    difference() {
        union() {
            translate([-leg_wall, -clip_width / 2, 0])
                cube([rim_gap + 2 * leg_wall, clip_width, bridge_thickness]);
            translate([-leg_wall, -clip_width / 2, -outside_drop])
                cube([leg_wall, clip_width, outside_drop + eps]);
            translate([rim_gap, -clip_width / 2, -inside_drop])
                cube([leg_wall, clip_width, inside_drop + eps]);
        }
        translate([-leg_wall - eps, cable_y,
                   bridge_thickness - cable_recess_depth])
            cube([rim_gap + 2 * leg_wall + 2 * eps, cable_width,
                  cable_recess_depth + eps]);
    }
}

module servo_pocket() {
    difference() {
        translate([box_left, -box_width / 2, box_bottom])
            cube([pocket_depth + face_thickness, box_width, box_height]);

        // Pocket behind the screw plate.
        translate([box_left + box_wall, -box_width / 2 + box_wall,
                   box_bottom + box_wall])
            cube([pocket_depth - box_wall + eps, box_width - 2 * box_wall,
                  box_height - 2 * box_wall]);

        // Insert the servo body from inside the tank, horn facing inward.
        translate([mount_x - eps, -opening_length / 2,
                   -servo_drop - opening_width / 2])
            cube([face_thickness + 2 * eps, opening_length, opening_width]);

        for (y = [-screw_pitch / 2, screw_pitch / 2])
            translate([mount_x - eps, y, -servo_drop])
                rotate([0, 90, 0])
                    cylinder(h = face_thickness + 2 * eps,
                             d = screw_diameter, $fn = 32);

        // Feed the plug through the pocket roof before seating the servo.
        translate([box_left + 4, -11, box_bottom + box_height - box_wall - eps])
            cube([14, 10, box_wall + 2 * eps]);

        // Drain a splash or condensation from the pocket.
        translate([box_left + 5, 0, box_bottom - eps])
            cylinder(h = box_wall + 2 * eps, d = 3, $fn = 24);
    }
}

// Rotate onto a side so the U-shaped clip prints in the XY plane.
translate([0, 0, clip_width / 2])
    rotate([90, 0, 0])
        union() {
            rim_clip();
            if (part == "bracket")
                servo_pocket();
        }
