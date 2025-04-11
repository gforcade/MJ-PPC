#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Schubert no doping dependence.
#! Calculated according to the model dielectric function (MDF) fitted by Schubert.

#! MATERIAL: disordered AlGaInP
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um] refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K

#! REFERENCE: M. Schubert, Isotropic dielectric functions of highly disordered AlxGa1-xInP (0<=x<=1) lattice matched to GaAs
#! J. Appl. Phys., Vol. 86, No. 4, 15 August 1999
#! HISTORY:
#! M Wilkins: 18 June 2015

package require math::complexnumbers
namespace eval AlGaInP::ComplexRefractiveIndex {
    proc init {} {
	# parameter table
	proc get_param { x p } {
		set a0 [lindex $p 0]
		set a1 [lindex $p 1]
		set b  [lindex $p 2]
		return [expr $a0 + $x*$a1 + $x*(1-$x)*$b]
 	}
	set xMole $::xMole
	set eps_inf [get_param $xMole [list 0.52 -0.08 -0.17 ]]
	set E0      [get_param $xMole [list 1.899 0.683 -0.12]]
	set A0      [get_param $xMole [list 10.44 11.34 -0.47]]
	set G0      [get_param $xMole [list 0.003 0.005 0.05 ]]

	set E1      [get_param $xMole [list 3.224 0.421 -0.13]]
	set A1      [get_param $xMole [list 5.27  -0.64 -1   ]]
	set G1	    [get_param $xMole [list 0.334 0      0.32]]

	set A1x     [get_param $xMole [list 1.79  0.07   1.46]]
	set G1x	    [get_param $xMole [list 0.295 0.046 -0.09]]
	set s1x     [get_param $xMole [list 0.42  0.6    0   ]]
	set p1x	    [get_param $xMole [list -0.76 0      0   ]]

	set E2	    [get_param $xMole [list 4.832 0.02   0   ]]
	set A2	    [get_param $xMole [list 2.19 -0.68   0.66]]
	set G2 	    [get_param $xMole [list 0.743 -0.159 0.05]]
	set s2      [get_param $xMole [list 0.88   0.49  0   ]]
	set p2	    [get_param $xMole [list 0.16   0.1  -0.1 ]]

	variable llist 
	variable nlist 
	variable klist 
	variable TableInterpolation Linear
	variable Formula 1

       namespace import ::math::complexnumbers::*

	# iterate over wavlengths
	set llist [list]
	for { set l 0.2 } { $l < 2.0 } { set l [expr $l + 0.005] } {
		lappend llist $l
		# photon energy in eV
		set E [expr 1.24/$l]

		set Chi0 [/ [complex $E $G0] [complex $E0 0]]
		set Chi1 [/ [complex $E $G1] [complex $E1 0]]

		# Schubert formula A1
		set t1  [pow [+ [complex 1 0] $Chi0] [complex 0.5 0]]
		set t2  [pow [- [complex 1 0] $Chi0] [complex 0.5 0]]
		set f1  [* [pow $Chi0 [complex -2 0]] [- [complex 2 0] [+ $t1 $t2]]]
		set eps0 [* [complex [expr $A0*$E0**(-1.5)] 0] $f1]

		# Formula A2
		# -A1*X1^-2
		set f1 [* [- [complex $A1 0]] [pow $Chi1 [complex -2 0]]]
		# ln(1-X1^2)
		set f2 [log [- [complex 1 0] [pow $Chi1 [complex 2 0]]]]
		set eps1 [* $f1 $f2 ]

		# Formula A3
		set num [* [complex $A1x 0] [exp [complex 0 $p1x]]]
		set den [complex [expr $E1 -$E] [expr -$G1x * exp(-$s1x * ($E1-$E)**2) ]]
		set eps1x [/ $num $den]

		# formula A4
		set num [* [complex $A2 0] [exp [complex 0 $p2]]]
		set t1 [expr 1-($E/$E2)**2]
		set t2 [expr (-$E/$E2)*($G2/$E2)*exp(-$s2*($E-$E2)**2)]
		set den [complex $t1 $t2]
		set eps2 [/ $num $den]
		puts "$eps_inf $eps0 $eps1 $eps1x $eps2"

		set eps [complex $eps_inf 0]
		set eps [+ $eps $eps0 ]
		set eps [+ $eps $eps1 ]
		set eps [+ $eps $eps1x]
		set eps [+ $eps $eps2 ]
	
		# complex index of refraction
		set nc [sqrt $eps]

		set n [real $nc]
		set k [imag $nc]

		# force k to zero for energies less than band gap.
		if { $E < $E0 } {
			set k 0.0
		}


		lappend nlist $n
		lappend klist $k
	}
    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
AlGaInP::ComplexRefractiveIndex::init
