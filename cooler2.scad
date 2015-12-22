// Width of clamp to 3d printer
clampwidth = 56;

// Depth (must be big enough for the notch)
clampdepth = 15;

// Thickness of acrylic
acrylthick = 8.5;
// Amount the clamp is thicker than the acrylic
clampover = 1.5;
// Width of notch
notchwidth = 12;
// Depth of notch
notchdepth = 8;
// Screw offset from center (left and right)
screwofs = 20;
// Radius of screw holes
screwrad = 1.5;
// Outer radius of cooler ring
ringrad = 25;
// Thickness of cooler ring
ringsize = 4;
// Thickness of cooler ring wall
wallthick = 1;
// Number of air holes
numholes = 16;
// Size of air holes
holesize = wallthick / 2;
// Width of air shaft
shaftwidth = 17.3;
// Depth of air shaft
riserdepth = 12;
// Length of shaft from outer radius of cooler ring
shaftlen = 30;
// Height of riser for fan
riserheight = 50;

// Thickness of fan step around riser
stepthick = 2;
// Offset below top of riser for step
stepofs = 6;

res = 180;

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
		}

		union() {
			// Hollow out ring
			translate([0, 0, wallthick / 2]) rotate_extrude(angle = 360, convexity = 2, $fn = res)
			    translate([ringrad + wallthick / 2, 0, 0]) square([ringsize - wallthick, ringsize - wallthick]);

			// Hollow out horizontal shaft
			translate([-shaftwidth / 2 + wallthick, ringrad + wallthick, wallthick])
			    cube([shaftwidth - wallthick * 2, shaftlen - wallthick * 2 * 0, riserdepth - wallthick * 2]);

			// Hollow out riser
			translate([-shaftwidth / 2 + wallthick, ringrad + shaftlen + wallthick, wallthick])
			    cube([shaftwidth - wallthick * 2, riserdepth - wallthick * 2, riserheight - wallthick]);

			// Blow holes
			for (i = [0:numholes]) {
				rotate([0, 0, i * 360 / numholes]) translate([ringrad - 0.5, 0, ringsize / 2])
				    rotate([0, 90, 0]) cylinder(r = (ringsize - wallthick) / 2, h = wallthick, $fn = res);
			}
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
			translate([clampwidth / 2 - screwofs, clampdepth, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth, r = screwrad, $fn = res);
			translate([clampwidth / 2 + screwofs, clampdepth, acrylthick / 2 + clampover])
			    rotate([90, 0, 0]) cylinder(h = clampdepth, r = screwrad, $fn = res);
		}
	}
}

//clamp();
//translate([0, 50, 0])
blower();
