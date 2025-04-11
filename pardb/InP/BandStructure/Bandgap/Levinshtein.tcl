#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/07/14 12:38:10 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: InP
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
#! VALIDITY: this model is valid for T = 0 K to 1000 K
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
##! Created on 2008/07/14 by Sameer Shah

namespace eval InP::Bandgap {
    proc init {} {
# Parameters from Levinshtein
	variable alpha 4.9e-04
	variable beta 327.0
	variable Tpar 0.0
	variable Eg0 1.421
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
            # In Levinshtein, Chi is defined for T=300K. Let this value be Chi300.              
            set Chi300 4.38
            # Calculate Chi0 using Chi300
   	    set Chi0 [expr {$Chi300 - $alpha*300.0*300.0/(2*(300.0 + $beta))} ]
            # Calculate Chi            
	    set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
        }		   	
    }
    proc print {} {printPar::BandgapSection}    
}
InP::Bandgap::init
