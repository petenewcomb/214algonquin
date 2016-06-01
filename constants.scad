use <units.scad>;

function basement_depth() = feet( 10);
function roof_height_max() = feet( 30) - basement_depth();

function roof_rvalue_min() = 49;
function exterior_wall_rvalue_min() = 21;
function rvalue_per_in_closed_cell_foam() = 6.5;
function rvalue_per_in_fiberglass() = 3;

function roof_thickness() = max( feet( 2), inches( 3) + inches( ceil( roof_rvalue_min() / rvalue_per_in_closed_cell_foam())));
function default_ceiling_height_min() = feet( 9);
function default_eaves_overhang() = feet( 3);

function default_font() = "Comic Sans MS:style=Regular";

function exterior_wall_thickness() = inches( 5.5) + inches( 1.5) + inches( 0.5);
function interior_wall_thickness() = inches( 3.5) + inches( 0.5) + inches( 0.5);
