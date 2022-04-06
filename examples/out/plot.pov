#version 3.7;
#include "povlab.inc"
#include "shapes.inc"
global_settings { assumed_gamma 1 }

camera { orthographic         angle 35
         location <0.00, 50.00, -0.00>
         right x * image_width / image_height
         look_at <0.00, 0.00, -0.00>
         right  <-1.33, 0.00, 0.000> rotate<90,0,0>}

light_source{< 20.0, 20.0, 20.0> rgb<0.90, 0.90, 0.90> }
#declare tex_axis_yellow = texture { Polished_Chrome
          pigment{ rgb <1.00, 1.00, 0.00>}
          finish { phong 1 reflection {0.10 metallic 0.4} }}

#declare tex_axis_gray = texture { Polished_Chrome
          pigment{ rgb <0.50, 0.50, 0.50>}
          finish { phong 1 reflection {0.10 metallic 0.4} }}

object{ axis_xyz( 11.00, 11.00, 0.00, 0.08,
        tex_axis_gray, tex_axis_yellow, tex_axis_yellow, tex_axis_z) }

#declare tex_plane_blue = texture { Polished_Chrome
          pigment{ rgb <0.30, 0.30, 0.30>}
          finish { phong 1 reflection {0.10 metallic 0.4} }}

plane { <0, 0, 1>, 0.00
        texture { tex_plane_blue }
        scale<1.00, 1.00, 1.00> rotate <0.00, 0.00, 0.00> translate <0.00, 0.00, 0.00>}

#local gid = "gid"
grid(gid, 1.00, 20, 20, 0.03, tex_grid_odd, tex_grid_even);
object { gid         scale<1.00, 1.00, 1.00> rotate <90.00, 0.00, 0.00> translate <0.00, 0.00, 0.00>}

#declare fgreen = function(X) { 4 * sin(X * pi/2) * ln(X) }
union {plot_function(0.00, 8.00, fgreen, 0.10, <0.0, 0.8, 0.00>)
        scale<1.00, 1.00, 1.00> rotate <0.00, 0.00, 0.00> translate <0.00, 0.00, 0.10>}

#declare fyellow = function(X) { sin(X * pi/2) * ln(-X) }
union {plot_function(-8.00, 0.00, fyellow, 0.10, <0.0, 0.0, 0.80>)
        scale<1.00, 1.00, 1.00> rotate <0.00, 0.00, 0.00> translate <0.00, 0.00, 0.10>}

#declare fred = function(X) { X * X * X / 12 }
union {plot_function(-8.00, 8.00, fred, 0.10, <1.0, 0.0, 0.00>)
        scale<1.00, 1.00, 1.00> rotate <0.00, 0.00, 0.00> translate <0.00, 0.00, 0.10>}

