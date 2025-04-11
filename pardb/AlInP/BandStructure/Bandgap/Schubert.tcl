#----------------------------------------------------------------------#
# $Id:$
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Piprek
#! MATERIAL: AlInP
#! PROPERTY: Bandgap
#! EXPRESSION: 
#! Temperature and mole fraction dependent Bandgap is calculated using
#! Eg(x,T)  =  Eg0(x) + alpha*Tpar^2/(Tpar + beta) - alpha*T/(T + beta)
#! Temperature dependent electron affinity is calculated using 
#! Chi(x,T) = Chi(x,Tpar)- alpha*Tpar^2/(Tpar + beta) + alpha*T^2/(2*(T + beta)) + Bgn2Chi*Ebgn
#! Ebgn   =  Bandgap narrowing [eV] depending on BGN model not set here!
#! CALCULATED PARAMETER: 
#! Eg returns Eg(x,T) [eV]
#! Chi returns Chi(x,T) with Ebgn = 0 [eV]
#! VALIDITY: 
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:  
#! Created on 2008/07/28 by Sameer Shah

namespace eval AlInP::Bandgap {
    proc init {} {        
	variable alpha 0.0
    	variable beta 1.0
	variable Tpar 0.0
	variable Eg0 [expr {2.24 + 0.18*$::xMole}]
	variable Chi0
	variable Eg
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egsubstrate 
	variable Chisubstrate

# Calculate Eg(x,T)
	set Eg [expr $Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)]    
  
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
            # Chi values from Piprek are used    
            # In Piprek, Chi is defined for T=300K. Let this value be Chi300. 
            set Chi300 [expr {4.4-0.42*$::xMole}];   #linear interpolation between electron affinity values of AlP and InP is assumed
            # Calculate Chi0 using Chi300
   	    set Chi0 [expr {$Chi300 - $alpha*300.0*300.0/(2*(300.0 + $beta))} ]
            # Calculate Chi
	    set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
        }
    }
    proc print {} {printPar::BandgapSection}    
}
AlInP::Bandgap::init
