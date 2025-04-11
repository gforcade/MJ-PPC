#----------------------------------------------------------------------#
# $Id: Palankovski.tcl,v 1.2 2007/08/10 12:17:02 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Palankovski
#! MATERIAL: GaAs
#! PROPERTY: Bandgap
#! EXPRESSION: 
#! Temperature dependent Bandgap is calculated using
#! Eg(T)  =  Eg0 + alpha*Tpar^2/(Tpar + beta) - alpha*T/(T + beta)
#! Temperature dependent electron affinity is calculated using 
#! Chi(T) = Chi(Tpar)- alpha*Tpar^2/(Tpar + beta) + alpha*T^2/(2*(T + beta)) + Bgn2Chi*Ebgn
#! Ebgn   =  Bandgap narrowing [eV] depending on BGN model not set here!
#! CALCULATED PARAMETER: 
#! Eg returns Eg(T) [eV]
#! Chi returns Chi(T) with Ebgn = 0 [eV]
#! VALIDITY: 
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 in the calculation of the parameter Bandgap::Chi.
#! The value of Chi0 is the sdevice default value.
#! SDEVICE: 
#! REFERENCE: 
#! "Analysis and Simulation of Heterostructure Devices", V. Palankovski, R.Quay
#! Springer-Verlag/Wien, 2004

namespace eval GaAs::Bandgap {
    proc init {} {
	variable alpha 5.5800e-04
	variable beta 2.2000e+02
	variable Tpar 0.0
	variable Eg0 1.5210
	variable Chi0
	variable Eg
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egreference 
	variable Chireference
      
	set Eg [expr $Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)]
	if {[info exists ::cbo]} {
	    set Egreference [evalVar "${::reference}::Bandgap::Eg"]
	    set Chireference [evalVar "${::reference}::Bandgap::Chi"]
	    puts "Egreference: $Egreference Chireference: $Chireference"
	    set Chi [expr $Chireference - $::cbo*($Eg - $Egreference)]
	    set Chi0 [expr $Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))]
	} else {
	    variable Chi0 4.07
	    set Chi [expr $Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))]	  
	}		   	
    }
    proc print {} {printPar::BandgapSection}    
}
GaAs::Bandgap::init
