clampwidth = 56;
clampdepth = 15;
acrylthick = 8.2;
clampover = 1.5; // Amount the clamp is thicker than the acrylic
notchwidth = 12;
notchdepth = 8;
screwofs = 20;
screwrad = 1.5;
res = 180;

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

clamp();
