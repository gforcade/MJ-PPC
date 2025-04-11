#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.1 2008/07/14 13:17:28 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: room temperature model from Levinshtein
#! MATERIAL: GaInP
#! PROPERTY: Bandgap
#! EXPRESSION: 
#! Temperature and mole fraction dependent bandgap is calculated using
#! Eg(x,T)  =  Eg0(x) + alpha*Tpar^2/(Tpar + beta) - alpha*T/(T + beta)
#! Temperature dependent electron affinity is calculated using 
#! Chi(x,T) = Chi(x,Tpar)- alpha*Tpar^2/(Tpar + beta) + alpha*T^2/(2*(T + beta)) + Bgn2Chi*Ebgn
#! Ebgn   =  Bandgap narrowing [eV] depending on BGN model not set here!
#! CALCULATED PARAMETER: 
#! Eg returns Eg(x,T) [eV]
#! Chi returns Chi(x,T) with Ebgn = 0 [eV]
#! VALIDITY: This model is valid only for T=300K and for 0 < x < 0.63 and 0.77 < x < 1
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2008/07/14 by Sameer Shah

namespace eval GaInP::Bandgap {
    proc init {} {
# Room temperature parameters from Levinshtein
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

# Calculate Chi0, Eg0 and define alpha,beta
        set Chi0 [expr {4.38-0.58*$::xMole}]
        if {$::xMole <= 0.63} {            
            set Eg0 [expr {1.34 + 0.69*$::xMole + 0.48*$::xMole*$::xMole}]
            set alpha 4.9e-4
            set beta 327
        } elseif {$::xMole >= 0.77} {            
            set Eg0 2.26
            set alpha 6.2e-4
            set beta 460
        } else {
            puts stderr "GaInP/Bandgap/Levinshtein-RT model is valid only for 0<x<0.63 and 0.77<x<1 ."
            exit -1
        }
                    

# Calculate Eg         
	set Eg [expr $Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)]
    
    	if {[info exists ::cbo]} {
	    if {[info exists ::substrate]} {
        # For heterostructures, substrate and cbo are defined. Calculate new Chi0 for heterostructures                 
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
GaInP::Bandgap::init
