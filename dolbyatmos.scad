use <math.scad>;

$fn=100;

function feet( x) = inches( x) * 12;
function inches( x) = x;

function pointer_diameter() = inches(5.0/16);
function pointer_length() = inches(2.0);
function socket_depth() = inches(1.0);
function sphere_radius() = inches(2.0);

function stereo_separation() = 20;

module pointer() {
    cylinder(r=pointer_diameter(),h=pointer_length());
}

module socket() {
    translate( [ 0, 0, sphere_radius() - socket_depth()]) pointer();
}

module forward_socket() {
    rotate( [ -90, 0, 0]) socket();
}

module center_socket() {
    rotate( [ 0, 0, 0]) forward_socket();
}

module lf_socket() {
    rotate( [ 0, 0, -stereo_separation()]) forward_socket();
}

module rf_socket() {
    rotate( [ 0, 0, stereo_separation()]) forward_socket();
}

module lfs_socket() {
    rotate( [ 0, 0, -60]) forward_socket();
}

module rfs_socket() {
    rotate( [ 0, 0, 60]) forward_socket();
}

module ls_socket() {
    rotate( [ 0, 0, -100]) forward_socket();
}

module rs_socket() {
    rotate( [ 0, 0, 100]) forward_socket();
}

module lrs_socket() {
    rotate( [ 0, 0, -(180-stereo_separation())]) forward_socket();
}

module rrs_socket() {
    rotate( [ 0, 0, (180-stereo_separation())]) forward_socket();
}

module flc_socket() {
    rotate( [ 45, 0, 0]) rotate( [ 0, 0, -stereo_separation()]) forward_socket();
}

module fcc_socket() {
    rotate( [ 45, 0, 0]) forward_socket();
}

module frc_socket() {
    rotate( [ 45, 0, 0]) rotate( [ 0, 0, stereo_separation()]) forward_socket();
}

module clc_socket() {
    rotate( [ 80, 0, 0]) rotate( [ 0, 0, -stereo_separation()]) forward_socket();
}

module ccc_socket() {
    rotate( [ 80, 0, 0]) forward_socket();
}

module crc_socket() {
    rotate( [ 80, 0, 0]) rotate( [ 0, 0, stereo_separation()]) forward_socket();
}

module rlc_socket() {
    rotate( [ 180 - 45, 0, 0]) rotate( [ 0, 0, -stereo_separation()]) forward_socket();
}

module rcc_socket() {
    rotate( [ 180 - 45, 0, 0]) forward_socket();
}

module rrc_socket() {
    rotate( [ 180 - 45, 0, 0]) rotate( [ 0, 0, stereo_separation()]) forward_socket();
}

translate( [ 0, 0, sphere_radius()]) {
    difference() {
        union() {
            sphere( sphere_radius());
            scale( [ 1, 1, -1]) cylinder( h=sphere_radius(), r=sphere_radius());
        }

        lf_socket();
        center_socket();
        rf_socket();

        lfs_socket();
        rfs_socket();

        ls_socket();
        rs_socket();

        lrs_socket();
        rrs_socket();

        flc_socket();
        fcc_socket();
        frc_socket();

        clc_socket();
        ccc_socket();
        crc_socket();

        rlc_socket();
        rcc_socket();
        rrc_socket();
    }
}
