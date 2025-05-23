#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.3 2007/08/28 11:57:39 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: room temperature model from Levinshtein
#! MATERIAL: GaAs
#! PROPERTY: Bandgap
#! EXPRESSION: 
#! Temperature dependent bandgap is calculated using
#! Eg(T)  =  Eg0 + alpha*Tpar^2/(Tpar + beta) - alpha*T/(T + beta)
#! Temperature dependent electron affinity is calculated using 
#! Chi(T) = Chi(Tpar)- alpha*Tpar^2/(Tpar + beta) + alpha*T^2/(2*(T + beta)) + Bgn2Chi*Ebgn
#! Ebgn   =  Bandgap narrowing [eV] depending on BGN model not set here!
#! CALCULATED PARAMETER: 
#! Eg returns Eg(T) [eV]
#! Chi returns Chi(T) with Ebgn = 0 [eV]
#! VALIDITY: this model is valid only for T=300K
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1996

namespace eval GaAs::Bandgap {
    proc init {} {
# Room temperature parameters from Levinshtein        
    	variable alpha 5.4050e-04
	    variable beta 2.0400e+02
	    variable Tpar 300.0
	    variable Eg0 1.424
	    variable Chi0 4.07
	    variable Eg
	    variable Chi
	    variable Bgn2Chi 0.5
	    variable Eg
	    variable Chi

    	variable Egsubstrate 
    	variable Chisubstrate 

# Calculate Eg                
	    set Eg [expr {$Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)}]
    	
        if {[info exists ::cbo]} {
	        if {[info exists ::substrate]} {
        # For heterostructures, substrate and cbo are defined. Calculate new Chi0 for heterostructures                
		        set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg0"]
		        set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi0"]
		        puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
		        set Chi0 [expr $Chisubstrate - $::cbo*($Eg0 - $Egsubstrate)]
	        } else {
		    puts stderr "Please specify the substrate material to calculate Chi according to cbo."
            exit -1
	        }
	    }
        
# Calculate Chi       
	    set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
    }
    proc print {} {printPar::BandgapSection}    
}
GaAs::Bandgap::init
