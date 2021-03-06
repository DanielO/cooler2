// Width of clamp to 3d printer
clampwidth = 56;

// Depth (must be big enough for the notch)
clampdepth = 15;

// Thickness of acrylic
acrylthick = 8.5;
// Amount the clamp is thicker than the acrylic (each side)
clampover = 1.5;
// Thickness of clamp
clampthick = acrylthick + 2 * clampover;
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
ringrad = 18;
// Thickness of cooler ring
ringsize = 5;
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
riserofs = 43.5;
// Length of shaft from outer radius of cooler ring
shaftlen = riserofs - ringrad;
// Height of riser for fan
riserheight = 50;

// Thickness of fan step around riser
stepthick = 2;
// Offset below top of riser for step
stepofs = 6;

// Height clamp mates with riser
clampofs = 19;

// X offset of clamp
clampxofs = -5;

// Add mount for inductive bed sensor
ind_sensor = 0;
// Radius of hole for inductive sensor
ind_sensorholerad = 9.5;
// Radius of mount for sensor
ind_sensormntrad = 15.25;
// Thickness of mount
ind_sensorthick = clampthick;

// Add mount for IR sensor
ir_sensor = 1;
// Screw radius
ir_holerad = 1.35;
// Hole centers
ir_holespacing = 24;
// Height to screw hole centres
ir_sensorheight = 21.75;
// Depth of bar holding sensor
ir_bardepth = 10;
// Height of bar holding sensor
ir_barheight = 8;
ir_barxofs = -12;
ir_baryofs = 0;

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
			// Angle to make easier to print
			anglez = stepthick * 3;
			translate([-shaftwidth / 2, ringrad + shaftlen, riserheight - stepofs - anglez - stepthick])
			    polyhedron(points = [[0, 0, 0], [shaftwidth, 0, 0], [shaftwidth, riserdepth, 0], [0, riserdepth, 0],
				    [-stepthick, -stepthick, anglez], [shaftwidth + stepthick, -stepthick, anglez], [shaftwidth + stepthick, riserdepth + stepthick, anglez], [-stepthick, riserdepth + stepthick, anglez]],
				faces = [[1, 0, 4, 5], [2, 1, 5, 6], [3, 2, 6, 7], [7, 4, 0, 3], [0, 1, 2, 3], [7, 6, 5, 4]]);

			// Place clamp
			rotate([0, 0, 180]) translate([-clampxofs + -clampwidth / 2, -shaftlen - ringrad, clampofs]) clamp();

			// Inductive sensor holder
			if (ind_sensor)
				ind_sensor_mount();

			// IR sensor
			if (ir_sensor)
				ir_sensor_mount();
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
				rotate([0, 0, (i + 1) * 360 / numholes]) translate([ringrad - 0.5, 0, 0])
				    rotate([0, 45, 0]) cylinder(r = (ringsize - ringwallthick) / 2, h = ringwallthick * 1.5, $fn = res);
			}

			// IR sensor screw holes
			if (ir_sensor)
				ir_sensor_mount_screw_holes();
			// Cut away to view internals
			//translate([6, -100, 0]) cube([100, 200, 100]);
		}
	}
}

module clamp() {
	difference() {
		union() {
			// Main block
			cube([clampwidth, clampdepth, clampthick]);
			// Angle to make it easier to print (cheats and uses shaftwidth, clampofs, clampxofs and riserdepth)
			polyhedron(points = [[0, 0, 0], [clampwidth, 0, 0], [clampwidth, clampdepth, 0], [0, clampdepth, 0],
				[clampwidth / 2 - shaftwidth / 2 + clampxofs, 0, -clampofs + riserdepth],
				[clampwidth / 2 + shaftwidth / 2 + clampxofs, 0, -clampofs + riserdepth],
				[clampwidth / 2 + shaftwidth / 2 + clampxofs, riserdepth / 2, -clampofs + riserdepth],
				[clampwidth / 2 - shaftwidth / 2 + clampxofs, riserdepth / 2, -clampofs + riserdepth]],
			    faces = [[0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7], [0, 3, 2, 1], [4, 5, 6, 7]]);
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

module ind_sensor_mount() {
	// +2 is fudge factor so circle is held strongly
	translate([-clampwidth / 2 - ind_sensormntrad + 2, clampdepth + shaftlen, clampofs]) {
		difference() {
			cylinder(r = ind_sensormntrad, h = ind_sensorthick, $fn = res);
			cylinder(r = ind_sensorholerad, h = ind_sensorthick, $fn = res);
		}
	}
}

module ir_sensor_mount() {
	_barwidth = ir_holerad * 6;
	// Outside block
	translate([- _barwidth - shaftwidth / 2 + ir_barxofs - ir_holespacing / 2, riserofs - ir_bardepth, ir_sensorheight]) {
		cube([_barwidth, ir_bardepth, ir_barheight]);
	}
	// Inside block
	// Skip otherwise it ocludes the mount hole
	//translate([- _barwidth - shaftwidth / 2 + ir_barxofs + ir_holespacing / 2, riserofs - ir_bardepth, ir_sensorheight]) {
	//	cube([_barwidth, ir_bardepth, ir_barheight]);
	//}
}

module ir_sensor_mount_screw_holes() {
	_barwidth = ir_holerad * 6;
	translate([- _barwidth - shaftwidth / 2 + ir_barxofs - ir_holespacing / 2 + ir_holerad, riserofs - ir_bardepth, ir_sensorheight]) {
		// Outside screwhole
		translate([ir_holerad + 1, ir_bardepth, ir_barheight / 2]) rotate([90, 0, 0]) cylinder(r = ir_holerad, h = ir_bardepth , $fn = res);
		// Inside screwhole
		translate([ir_holerad + ir_holespacing + 1, ir_bardepth, ir_barheight / 2]) rotate([90, 0, 0]) cylinder(r = ir_holerad, h = clampthick, $fn = res);
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
