// Width of clamp to 3d printer
clampwidth = 56;

// Depth (must be big enough for the notch)
clampdepth = 15;

// Thickness of acrylic
acrylthick = 8.5;
// Amount the clamp is thicker than the acrylic (each side)
clampover = 1.5;
// Width of notch
notchwidth = 12;
// Depth of notch
notchdepth = 8;
// Bump to hold fan on better
bumpsize = 0.5;
numbumps = 5;
// Screw offset from center (left and right)
screwofs = 20;
// Radius of screw holes
screwrad = 1.5;
// Inner radius of cooler ring
ringrad = 21;
// Thickness of cooler ring
ringsize = 6;
// Thickness of cooler ring wall
ringwallthick = 2;
// Number of air holes
numholes = 10;
// Size of air holes
holesize = ringwallthick / 2;
// Thickness of cooler ring wall
shaftwallthick = 1.5;
// Width of air shaft
shaftwidth = 17.3;
// Depth of air shaft
riserdepth = 12;
// Offset from hotend centre to riser
riserofs = 50;
// Length of shaft from outer radius of cooler ring
shaftlen = riserofs - ringrad;
// Height of riser for fan
riserheight = 50;

// Thickness of fan step around riser
stepthick = 2;
// Offset below top of riser for step
stepofs = 6;

// Height clamp mates with riser
clampofs = 20;

// Radius of hole for inductive sensor
sensorholerad = 9;
// Radius of mount for sensor
sensormntrad = 15;
// Thickness of mount
sensorthick = acrylthick + 2 * clampover;

res = 90;

module blower() {
	difference() {
		union() {
			// Create solid ring
			rotate_extrude(angle = 360, convexity = 2, $fn = res)
			    translate([ringrad, 0, 0]) square([ringsize, ringsize]);

			// Horizontal shaft to fan riser
			translate([-shaftwidth / 2, ringrad, 0]) cube([shaftwidth, shaftlen, riserdepth]);

			// Riser to fan
			translate([-shaftwidth / 2, ringrad + shaftlen, 0]) cube([shaftwidth, riserdepth, riserheight]);

			// Step to rest fan on
			translate([-shaftwidth / 2 - stepthick, ringrad + shaftlen - stepthick, riserheight - stepofs - stepthick])
			    cube([shaftwidth + stepthick * 2, riserdepth + stepthick * 2, stepthick]);

			// Bumps to hold the fan in place more firmly
			for (i = [0:numbumps - 1]) {
				xofs = -shaftwidth / 2 + bumpsize + i / (numbumps - 1) * (shaftwidth - bumpsize * 2);
				zofs1 = riserheight - stepofs + bumpsize + i / (numbumps - 1) * (stepofs - bumpsize * 2);
				zofs2 = riserheight - stepofs + bumpsize  + (numbumps - i - 1) / (numbumps - 1) * (stepofs - bumpsize * 2);
				translate([xofs, ringrad + shaftlen, zofs1])
				    rotate([180, 0, 0]) bump();
				translate([xofs, ringrad + shaftlen + riserdepth, zofs2])
				    bump();
			}
			// Place clamp
			rotate([0, 0, 180]) translate([-clampwidth / 2, -shaftlen - ringrad - shaftwallthick, clampofs]) clamp();

			// Sensor holder
			sensor_mount();
		}

		union() {
			// Hollow out ring
			r = (ringsize - ringwallthick) / 2;
			translate([0, 0, ringwallthick / 2 + r]) rotate_extrude(angle = 360, convexity = 2, $fn = res)
			    translate([ringrad + ringwallthick / 2 + r, 0, 0]) circle(r = r);

			// Hollow out horizontal shaft
			// XXX: Assumes riserdepth is <= shaftwidth
			rshaft = (riserdepth - shaftwallthick * 2) / 2;
			translate([0, ringrad + ringsize / 2, rshaft + shaftwallthick])
			    rotate([270, 0, 0]) cylinder(r = rshaft, h = shaftlen);

			// Hollow out riser
			translate([-shaftwidth / 2 + shaftwallthick, ringrad + shaftlen + shaftwallthick, shaftwallthick])
			    cube([shaftwidth - shaftwallthick * 2, riserdepth - shaftwallthick * 2, riserheight - shaftwallthick]);

			// Blow holes
			for (i = [0:numholes]) {
				rotate([0, 0, (i + 1) * 360 / numholes]) translate([ringrad - 0.5, 0, ringsize / 2 - 3])
				    rotate([0, 45, 0]) cylinder(r = (ringsize - ringwallthick) / 2, h = ringwallthick * 2, $fn = res);
			}

			// Cut away to view internals
			//translate([0, -100, 0]) cube([100, 200, 100]);
		}
	}
}

module clamp() {
	difference() {
		union() {
			// Main block
			cube([clampwidth, clampdepth, acrylthick + 2 * clampover]);
		}
		union() {
			// Notch
			translate([(clampwidth - notchwidth) / 2, clampdepth - notchdepth, clampover])
			    cube([notchwidth, notchdepth, acrylthick]);
			// Screw holes
			translate([clampwidth / 2 - screwofs, clampdepth, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth / 2, r = screwrad, $fn = res);
			translate([clampwidth / 2 + screwofs, clampdepth, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth, r = screwrad, $fn = res);
			// Screw recess
			translate([clampwidth / 2 - screwofs, clampdepth / 2, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth / 2, r = screwrad * 2, $fn = res);
			translate([clampwidth / 2 + screwofs, clampdepth / 2, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth / 2, r = screwrad * 2, $fn = res);
		}
	}
}

module sensor_mount() {
	// XXX: -1 fudge otherwise it collides with the screwhead cut out
	translate([-clampwidth / 2 - sensorholerad - 1, clampdepth + shaftlen, clampofs]) {
		difference() {
			cylinder(r = sensormntrad, h = sensorthick, $fn = res);
			cylinder(r = sensorholerad, h = sensorthick, $fn = res);
		}
	}
}

// Create a bump perpendicular to the XZ plane extending into +Y
module bump() {
	difference() {
		sphere(r = bumpsize, $fn = res / 2);
		translate([-bumpsize, -bumpsize, -bumpsize]) cube([bumpsize * 2, bumpsize, bumpsize * 2]);
	}
}

blower();
