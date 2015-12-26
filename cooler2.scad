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
// Screw offset from center (left and right)
screwofs = 20;
// Radius of screw holes
screwrad = 1.5;
// Inner radius of cooler ring
ringrad = 15;
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
// Length of shaft from outer radius of cooler ring
shaftlen = 35;
// Height of riser for fan
riserheight = 50;

// Thickness of fan step around riser
stepthick = 2;
// Offset below top of riser for step
stepofs = 6;

// Height clamp mates with riser
clampofs = 20;

gaugeblockheight = 16.5;
gaugeblockwidth = 20;
gaugeblockdepth = 29.2;
gaugescrewrad = 3.2;
gaugescrewrecess = 2;
gaugescrewdepth = 11.4;
gaugeslotwidth = 5.2;
gaugeslotheight = 16.5;
gaugeslotdepth = 19.1;

gaugeriserofs = riserheight - 4;
gaugeriserheight = 19;
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
			translate([-shaftwidth / 2 - stepthick, ringrad + shaftlen - stepthick, riserheight - stepofs])
			    cube([shaftwidth + stepthick * 2, riserdepth + stepthick * 2, stepthick]);

			// Angle to make easier to print
			anglez = stepthick * 3;
			translate([-shaftwidth / 2, ringrad + shaftlen, riserheight - stepofs - anglez])
			    polyhedron(points = [[0, 0, 0], [shaftwidth, 0, 0], [shaftwidth, riserdepth, 0], [0, riserdepth, 0],
				    [-stepthick, -stepthick, anglez], [shaftwidth + stepthick, -stepthick, anglez], [shaftwidth + stepthick, riserdepth + stepthick, anglez], [-stepthick, riserdepth + stepthick, anglez]],
				faces = [[1, 0, 4, 5], [2, 1, 5, 6], [3, 2, 6, 7], [7, 4, 0, 3], [0, 1, 2, 3], [7, 6, 5, 4]]);

			// Place clamp
			rotate([0, 0, 180]) translate([-clampwidth / 2, -shaftlen - ringrad - shaftwallthick, clampofs]) clamp();

			// Depth gauge holder
			//translate([-15, 70, gaugeriserofs]) rotate([0, 0, 180]) gauge_holder();
			//translate([-28, 36.5, gaugeriserofs - 26 + 10]) cube([10, 15, 32.5]);
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
			// Angle to make it easier to print (cheats and uses shaftwidth, clampofs and riserdepth)
			polyhedron(points = [[0, 0, 0], [clampwidth, 0, 0], [clampwidth, clampdepth, 0], [0, clampdepth, 0],
				[clampwidth / 2 - shaftwidth / 2, 0, -clampofs + riserdepth],
				[clampwidth / 2 + shaftwidth / 2, 0, -clampofs + riserdepth],
				[clampwidth / 2 + shaftwidth / 2, riserdepth / 2, -clampofs + riserdepth],
				[clampwidth / 2 - shaftwidth / 2, riserdepth / 2, -clampofs + riserdepth]],
			    faces = [[0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7], [0, 3, 2, 1], [4, 5, 6, 7]]);

		}
		union() {
			// Notch
			translate([(clampwidth - notchwidth) / 2, clampdepth - notchdepth, clampover])
			    cube([notchwidth, notchdepth, acrylthick]);
			// Screw holes
			translate([clampwidth / 2 - screwofs, clampdepth / 2, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth / 2, r = screwrad, $fn = res);
			translate([clampwidth / 2 + screwofs, clampdepth / 2, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth / 2, r = screwrad, $fn = res);
			// Screw recess
			translate([clampwidth / 2 - screwofs, clampdepth, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth / 2, r = screwrad * 2, $fn = res);
			translate([clampwidth / 2 + screwofs, clampdepth, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth / 2, r = screwrad * 2, $fn = res);
		}
	}
}

module gauge_holder() {
	difference() {
		// Block to hold depth gauge
		cube([gaugeblockwidth, gaugeblockdepth, gaugeblockheight]);
		union() {
			// Slot it goes into
			translate([(gaugeblockwidth - gaugeslotwidth) / 2, 0, (gaugeblockheight - gaugeslotheight) / 2]) cube([gaugeslotwidth, gaugeslotdepth, gaugeslotheight]);
			// Screw hole
			translate([0, gaugescrewdepth, gaugeblockheight / 2]) rotate([0, 90, 0]) cylinder(r = gaugescrewrad, h = gaugeblockwidth);
			// Recess
			translate([0, gaugescrewdepth, gaugeblockheight / 2]) rotate([0, 90, 0]) cylinder(r = gaugescrewrad * 1.5, h = gaugescrewrecess);
		}
	}
}

blower();
//gauge_holder();
