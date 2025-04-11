# CVS: @(#) $Id: compound_lib.tcl,v 1.2 2007/08/28 11:59:47 sameers Exp $
#
#   This file defines procedures for making interpolations
#   of material parameters for compound materials.
#
# Copyright (c) 2003 by ISE Integrated Systems Engineering AG
#
#  History:
#  04.07.2003 - Pavel Tikhomirov, ISE AG
#  fixed the bug in compute_2_2_quaternary function
#

# compute_ternary --
#
#   This procedure returns the ternary A(x)B(1-x)C material parameter
#   by an interpolation between the binary compounds AB and BA with
#   a bowing factor for nonlinearities. 
#
#   P(A(x)B(1-x)C) = AB*x+BC*(1-x)-K*x*(1-x)
# 
# Arguments:
#   x -        mole fraction of compound AB
#   AB -       AB binary compound parameter value
#   BC -       BC binary compound parameter value
#   K -        bowing factor (note the minus sign here)

proc ::compute_ternary {x AB AC {K 0}} {
  expr $AB*$x+$AC*(1-$x)-$K*$x*(1-$x)
}

# compute_2_2_quaternary --
#
#   This procedure returns the quaternary alloy A(1-x)B(x)C(y)D(1-y)
#   material parameter from an interpolation between the four ternary
#   alloys ABC, ABD, BCD, and ACD. 
#
# V(A(1-x)B(x)C(y)D(1-y)) = (x*(1-x)*(y*ABC+(1-y)*ABD)+
#                            y*(1-y)*(x*BCD+(1-x)*ACD))/(x*(1-x)+y*(1-y))
# Arguments:
#   x -        mole fraction of compound BCD  
#   y -        mole fraction of compound ABC
#   ABC -      ABC ternary compound parameter value
#   ABD -      ABD ternary compound parameter value
#   BCD -      BCD ternary compound parameter value
#   ACD -      ACD ternary compound parameter value
proc ::compute_2_2_quaternary {x y ABC ABD BCD ACD} {
  expr ($x*(1-$x)*($y*$ABC+(1-$y)*$ABD)+$y*(1-$y)*($x*$BCD+(1-$x)*$ACD))/ \
       ($x*(1-$x)+$y*(1-$y))
}

# comp_3_1_QB --
#
#   This procedure returns the quaternary alloy A(x)B(y)C(1-x-y)D
#   material parameter from an interpolation between the three binary
#   alloys AD, BD, and CD with bowing parameters for the ternaries
#   ABD ACD BCD
#
# Arguments:
#   x  -        mole fraction of compound BCD  
#   y  -        mole fraction of compound ABC
#   AD -      AD binary compound parameter value
#   BD -      BD binary compound parameter value
#   CD -      CD binary compound parameter value
#   k_ABD -   bowing for ABD ternary side material, default value = 0
#   k_ACD -   bowing for ACD ternary side material, default value = 0
#   k_BCD -   bowing for BCD ternary side material, default value = 0
proc ::comp_3_1_QB {x y AD BD CD {k_ABD 0} {k_ACD 0} {k_BCD 0}} {
# Check that x & y mole fractions are in the allowed range
# A(x)B(y)C(1-x-y)D alloy =>
# 0 < x < 1
# 0 < y < 1
# 0 < x+y < 1
set xy_sum [expr {$x+$y}]
if { $x > 1.0 || $x < 0.0 || $y > 1.0 || $y < 0.0 || $xy_sum > 1.0 || $xy_sum < 0.0 } { 
 puts "Molefraction x: $x  y: $y out of range!"
 exit -1
}
set ABCD  [expr {$x*$AD+$y*$BD+(1-$x-$y)*$CD-$x*$k_ACD-$y*$k_BCD-(1-$x-$y)*$k_ABD}]
return $ABCD
}

# comp_quaternary --
#
#   This procedure returns the quaternary alloy 
#   material parameter from an second order interpolation between 
#   the three binary alloys B1, B2, B3 and B4 with bowing parameters 
#   of ternary alloys C12, C14, C23 and C34 and quaternary bowing
#   parameter D. The interpolation formula can beexpressed as an
#   inner product with a 3x3 matrix for the alloy parameters
#
#                           |B1  C12  B2 | | 1-x  |
#    Q(x,y) = [y y(1-y) 1-y]|C14  D   C23|x|x(1-x)| 
#                           |B4  C34  B3 | |  x   |
#   
#    Q(x,y) = y(1-x)B1+xyB2+(1-y)xB3+(1-x)(1-y)B4+...
#
#          (0,1)  (1,1)
#            B1----B2
#            |     |
#            |     |
#            B4----B3
#    (x,y)=(0,0)  (1,0)
#     
#
#   See Donati et al. JAP 94 (9) p. 5814 (2003)
#
# Arguments:
#   x  -      mole fraction of compound   
#   y  -      mole fraction of compound 
#   B1 -      binary compound B1 parameter value (x,y) = (0,1)
#   B2 -      binary compound B2 parameter value (x,y) = (1,1) 
#   B3 -      binary compound B3 parameter value (x,y) = (1,0)
#   B4 -      binary compound B4 parameter value (x,y) = (0,0)
#   C12 -     bowing for ternary side material, default value = 0
#   C23 -     bowing for ternary side material, default value = 0
#   C34 -     bowing for ternary side material, default value = 0
#   C14 -     bowing for ternary side material, default value = 0
#   D  -      quaternary bowing parameter, default value = 0
proc ::comp_quaternary {x y B1 B2 B3 B4 {C12 0} {C23 0} {C34 0} {C14 0} {D 0}} {
set compound_debug 0;
# Check that x & y mole fractions are in the allowed range
# 0 < x < 1
# 0 < y < 1
if { $x > 1.0 || $x < 0.0 || $y > 1.0 || $y < 0.0 } { 
 puts "Molefraction x: $x  y: $y out of range!"
 exit -1
}
if {$compound_debug == 1} {
    puts [format "x:  %.5g" $x]
    puts [format "y:  %.5g" $y]
    puts [format "B1: %.5g" $B1]
    puts [format "B2: %.5g" $B2]
    puts [format "B3: %.5g" $B3]
    puts [format "B4: %.5g" $B4]
}
set bilinear [expr {$y*(1-$x)*$B1+$x*$y*$B2+(1-$y)*$x*$B3+(1-$x)*(1-$y)*$B4}]
set ternary_bowing [expr {$x*(1-$x)*(1-$y)*$C34+$x*(1-$x)*$y*$C12+\
			      (1-$x)*$y*(1-$y)*$C14+$x*$y*(1-$y)*$C23}]
set Q [expr {$bilinear+$ternary_bowing+$x*(1-$x)*$y*(1-$y)*$D}]
if { $compound_debug == 1 } {
    puts [format "Bilinear:       %.5g" $bilinear]
    puts [format "Ternary_bowing: %.5g" $ternary_bowing]
    puts [format "Q:              %.5g" $Q]
}
return $Q
}

# mu2eV --
#
#  converts photon wavelength in um to photon energy in eV
#  or photon energy in eV to photon wavelength in um
#
#   value 1.23984 = h*c0/e*1e6 um*eV
#
# Arguments:
#   photon_wavelength_energy -   photon wavelength in um or photon energy in eV
proc ::mu2eV {photon_wavelength_energy} {
expr {1.23984/$photon_wavelength_energy}
}

# refIndex --
#
#  computes the refractive index below the bandgap in compound
#  semiconductor using Adachis model [1].
#
#   [1] S. Adachi JAP 53 (12) pp 8775-8792 (1982), + Textbook
#
# Arguments:
#   E   -   photon energy in eV (should be lower than bandgap Eg)
#   Eg  - bandgap in eV
#   so  - spin-orbit splitoff energy in eV
#   A   - oscillator stength for Eg transition, mole fraction 
#         dependent fitting parameter
#   B   - oscillator stength for Eg+so transition, mole fraction 
#         dependent fitting parameter
proc ::refIndex {E Eg so A B} {
# Check input arguments
    if { $E > $Eg } {
	puts "WARNING, refractive index model not valid for photon energies above bandgap"
        puts [format "Photon energy: %.3g eV, bandgap: %.3g eV" $E $Eg]
    }
    set z    [expr {$E/$Eg}]
    set z0   [expr {$E/($Eg+$so)}]
    set f_z  [expr {(2.0-sqrt(1+$z)-sqrt(1-$z))/($z*$z)}]
    set f_z0 [expr {(2.0-sqrt(1+$z0)-sqrt(1-$z0))/($z0*$z0)}]
    set h    [expr {$f_z+0.5*$f_z0*pow(($Eg/($Eg+$so)),1.5)}]
    set n    [expr {sqrt($A*$h+$B)}]
return $n
}

#Local Variables:
#mode:tcl
#End:
