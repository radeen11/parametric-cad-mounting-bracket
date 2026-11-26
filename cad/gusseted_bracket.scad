/*
Parametric gusseted L-bracket — portfolio adaptation, 2026.
Reference concept: Samet Ozer, Parametric Filleted L-Bracket,
https://github.com/scaletr/openscad_md/blob/main/L_bracket/L_bracket_v3.scad
MIT-licensed reference: see LICENSE-REFERENCE.txt.
Geometry rewritten with six mounting holes, two optional side webs
and configurable parameters. Units mm; NOT load-rated.
*/

/* [Bracket dimensions in mm] */
width=80;
base_depth=65;
upright_height=70;
thickness=5;

/* [Mounting holes in mm] */
hole_diameter=6.6;
hole_x_spacing=50;
base_hole_front=17;
base_hole_back=42;
upright_hole_height=46;

/* [Triangular reinforcement] */
gussets_enabled=true;
web_thickness=4;
gusset_reach=31;
gusset_height=35;
web_side_inset=7;

/* [Render quality] */
$fn=80;

// Geometric bounds only; these assertions do not verify load capacity.
assert(width>0 && base_depth>0 && upright_height>0 && thickness>0);
assert(thickness<min(base_depth,upright_height)/2);
assert(hole_diameter>0 && hole_diameter<thickness*3);
assert(hole_x_spacing>0 && (hole_x_spacing/2+hole_diameter/2)<width/2);
assert(base_hole_front>hole_diameter/2 && base_hole_back<base_depth-thickness-hole_diameter/2);
assert(base_hole_back>base_hole_front+hole_diameter);
assert(upright_hole_height>thickness+hole_diameter/2 &&
       upright_hole_height<upright_height-hole_diameter/2);
assert(web_thickness>0 && web_side_inset>web_thickness/2);
assert(gusset_reach<base_depth-thickness && gusset_height<upright_height-thickness);

module raw_bracket(){
    union(){
        translate([-width/2,0,0])cube([width,base_depth,thickness]);
        translate([-width/2,base_depth-thickness,0])
            cube([width,thickness,upright_height]);
        if(gussets_enabled){
            for(side=[-1,1]){
                translate([side*(width/2-web_side_inset)-web_thickness/2,0,0])
                    rotate([0,90,0])linear_extrude(height=web_thickness)
                        polygon(points=[
                            [-thickness,base_depth-thickness],
                            [-thickness,base_depth-thickness-gusset_reach],
                            [-thickness-gusset_height,base_depth-thickness]
                        ]);
            }
        }
    }
}

module bracket(){
    difference(){
        raw_bracket();
        // Base mounting holes through horizontal plate (Z)
        for(x=[-hole_x_spacing/2,hole_x_spacing/2])
            for(y=[base_hole_front,base_hole_back])
                translate([x,y,-1])cylinder(d=hole_diameter,h=thickness+2);
        // Upright mounting holes through vertical plate (Y)
        for(x=[-hole_x_spacing/2,hole_x_spacing/2])
            translate([x,base_depth+1,upright_hole_height])
                rotate([90,0,0])cylinder(d=hole_diameter,h=thickness+2);
    }
}

bracket();
