#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.4 2007/08/28 11:57:39 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
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
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! Sentaurus Device User Guide 

namespace eval GaAs::Bandgap {
    proc init {} {
# default parameters from sdevice
	    variable alpha 5.4050e-04
    	variable beta 2.0400e+02
	    variable Tpar 300.0
    	variable Eg0 1.424 ;# GaAs
#   	variable Eg0 1.4022 ;# In001Ga099As
	    variable Chi0
    	variable Eg
	    variable Chi 	 
    	variable Bgn2Chi 0.5     
	    variable Egsubstrate 
    	variable Chisubstrate

# Calculate Eg     
	    set Eg [expr {$Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)}]

        # Calculate Chi0 and Chi            
	    if {[info exists ::cbo]} {
            if {[info exists ::substrate]} {
        # For heterostructures, substrate and cbo are defined. Calculate Chi for heterostructures                 
	            set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
	            set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
	            puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
	            set Chi [expr {$Chisubstrate - $::cbo*($Eg - $Egsubstrate)}]
	            set Chi0 [expr {$Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
	        } else {
                puts stderr "Please specify the substrate material to calculate Chi according to cbo."
                exit -1
            }
        } else {
        # Calculate Chi for bulk            
            set Chi0 4.07
	        set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]	  
	    }		   	
    }
    proc print {} {printPar::BandgapSection}    
}
GaAs::Bandgap::init
