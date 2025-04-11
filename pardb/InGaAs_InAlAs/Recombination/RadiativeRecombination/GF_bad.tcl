#----------------------------------------------------------------------#
# $Id: GF.tcl,v 1.1 2022/03/29 20:02:02  Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: InGaAs
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)   
#! Temperature dependence is suppressed by setting alpha=0
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: This model is valid only for T=300K
#! NOTES: 
#! calculating the Brad coefficient using therer formula, which uses nk data
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! Dagan et al. "Minority carrier recombination of ordered GaInP at high temperatures," 2016.
#! created by Gavin Forcade 2022

package require math::interpolate
package require math::calculus


namespace eval InGaAs::RadiativeRecombination {
    proc init {} {


	#function to grab  nk data
	proc readTable {file tableType} {
	    set FID [open $file r]
	    set i 0
	    set Elist [list]
	    set nlist [list]
	    set klist [list]
	    while {[gets $FID line] >= 0} {
		    if {[scan $line "%e,%e,%e" l n k] == 3 } {
		        lappend Elist [expr $::h*$::c/($l*pow(10,-6)*$::q)]
		        lappend nlist $n
		        lappend klist $k
		        incr i
	    	}
	    }
	    set Enklist [list $Elist $nlist $klist]
	    return $Enklist
        close $FID
	}

	
	# get constants 
	source ../../../../lib/PhysicalConstants.tcl



	#get bandgap from file
	source ../../../../pardb/InGaAs/BandStructure/Bandgap/Piprek_rev.tcl
	set Eg [evalVar "${::material}::Bandgap::Eg"]

	#get eDOSMass from file
	source ../../../../pardb/InGaAs/BandStructure/eDOSMass/Ioffe.tcl
	set Nc [evalVar "${::material}::eDOSMass::Nc"]

	#get hDOSMass from file
	source ../../../../pardb/InGaAs/BandStructure/hDOSMass/Ioffe.tcl
	set Nv [evalVar "${::material}::hDOSMass::Nv"]

	
	#get optical constants
	set dataFile ../../../../pardb/InGaAs/Optics/ComplexRefractiveIndex/ISE_ISE/In53GaAs.dat
	set tableType TableODB
	#energy in eV
	set Enklist [readTable $dataFile $tableType]
	set Elist [lreverse [lindex $Enklist 0]]
	set nlist [lreverse [lindex $Enklist 1]]
	set klist [lreverse [lindex $Enklist 2]]
	set alist [lmap x $klist y $Elist {expr {4.0*$::pi*$x*$y*$::q/($::h*$::c)}}]

	#interpolate to create dense mesh for integration
	set a_coeffs [::math::interpolate::prepare-cubic-splines $Elist $alist]
	set n_coeffs [::math::interpolate::prepare-cubic-splines $Elist $nlist]
	set E [linspace [lindex $Elist 0] [lindex $Elist end] 10000]
	set n [lmap x $E {::math::interpolate::interp-cubic-splines $n_coeffs $x}]
	set a [lmap x $E {::math::interpolate::interp-cubic-splines $a_coeffs $x}]
	set dE [expr [lindex $E 1] - [lindex $E 0]]

	#integrate the integrad part of the equation
	set int_result [lmap x $E y $n z $a {expr pow($x*$y,2.0)*$z/(exp($x/($::kBeV*$::temp)) - 1.0)*$dE}]	
	set int_sum [expr [join $int_result +]]	


	set ni2 [expr $Nc*$Nv*exp(-$Eg/($::kBeV*$::temp))]
	## They had typo in their paper, should be 8pi and not 2pi
	variable C [expr {8.0*$::pi*$int_sum/($ni2*pow($::heV*100,3.0)*pow($::c,2.0))}]   
	puts $C
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
InGaAs::RadiativeRecombination::init
