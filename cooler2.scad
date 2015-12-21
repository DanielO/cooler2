clampwidth = 56;
clampdepth = 15;
acrylthick = 8.2;
notchwidth = 12;
notchdepth = 8;
screwofs = 14;
screwrad = 1.5;
res = 180;

module clamp() {
       difference() {
	       union() {
		       cube([clampwidth, clampdepth, acrylthick]);
	       }
	       union() {
		       translate([(clampwidth - notchwidth) / 2, clampdepth - notchdepth, 0]) cube([notchwidth, notchdepth, acrylthick]);
		       translate([clampwidth / 2 - screwofs, clampdepth, acrylthick / 2]) rotate([90, 0, 0]) cylinder(h = clampdepth, r = screwrad, $fn = res);
		       translate([clampwidth / 2 + screwofs, clampdepth, acrylthick / 2]) rotate([90, 0, 0]) cylinder(h = clampdepth, r = screwrad, $fn = res);
		    }
       }
}

clamp();
