#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/08/28 11:57:39 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from sdevice
#! MATERIAL: AlGaAs
#! PROPERTY: Bandgap
#! EXPRESSION: 
#! Temperature and mole fraction dependent bandgap is calculated using
#! Eg(x,T)  =  Eg0(x) + alpha*Tpar^2/(Tpar + beta) - alpha*T/(T + beta)
#! Temperature and mole fraction dependent electron affinity is calculated using 
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
#! Sentaurus Device User Guide 
#! HISTORY: 
#! Created on 2007/08/22 by Sameer Shah

namespace eval AlGaAs::Bandgap {
    proc init {} {
# Parameters from sdevice
    	variable alpha 
	    variable beta 
	    variable Tpar 300.0
	    variable Eg0 
	    variable Chi0 
	    variable Eg
	    variable Chi
	    variable Bgn2Chi 0.5
	    variable Eg
	    variable Chi

    	variable Egsubstrate 
    	variable Chisubstrate 

# Room temperature electron affinity and bandgaps from sdevice
        if {$::xMole < 0.45} {
            set Eg0 [expr {1.25038*$::xMole + 1.42248}]
            set alpha [expr {5.405e-4 - 1.4051e-4*$::xMole}]
            set beta [expr {204.0 - 204.0*$::xMole}]
            set Chi0 [expr {4.11826-1.20724*$::xMole}]              
            } else {
                set Eg0 [expr {0.143*$::xMole*$::xMole + 0.01965*$::xMole + 1.94735}]
                set alpha [expr {5.4049e-4 - 1.40491e-4*$::xMole}]
                set beta [expr {204.0 - 204.0*$::xMole}]
                set Chi0 [expr {3.5873 - 0.02727*$::xMole}]
            }    

# Calculate Eg
	    set Eg [expr {$Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)}]
     
    	if {[info exists ::cbo]} {
	        if {[info exists ::substrate]} {
        # For heterostructures, substrate and cbo are defined. Calculate Chi0 for heterostructures                 
		        set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg0"]
		        set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi0"]
		        puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
		        set Chi0 [expr {$Chisubstrate - $::cbo*($Eg0 - $Egsubstrate)}]
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
AlGaAs::Bandgap::init
