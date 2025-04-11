#----------------------------------------------------------------------#
# $Id: Thurmond.tcl,v 1.2 2007/08/10 12:17:02 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Thurmond
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
#! C.D.Thurmond, "The Standard Thermodynamic Function of the Formation of Electron and Holes in Ge, Si, GaAs and GaP", J. Electrochem. Soc., vol. 122, pp. 1133, 1975
#! HISTORY:  
#! Created on 07/06/2007 by Sameer Shah
						

namespace eval GaAs::Bandgap {
    proc init {} {
# Parameters from Thurmond
	variable alpha 5.4050e-04
	variable beta 2.0400e+02
	variable Tpar 0.0
	variable Eg0 1.519
	variable Chi0
	variable Eg
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egsubstrate 
	variable Chisubstrate

# Calculation of Eg and Chi      
	set Eg [expr $Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)]
	if {[info exists ::cbo]} {
	    set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
	    set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
	    puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
	    set Chi [expr $Chisubstrate - $::cbo*($Eg - $Egsubstrate)]
	    set Chi0 [expr $Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))]
	} else {
	    variable Chi0 4.07
	    set Chi [expr $Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))]	  
	}		   	
    }
    proc print {} {printPar::BandgapSection}    
}
GaAs::Bandgap::init
