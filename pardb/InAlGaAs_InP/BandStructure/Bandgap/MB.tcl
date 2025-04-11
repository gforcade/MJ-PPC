#----------------------------------------------------------------------#
# $Id: MB.tcl, 2019/07/11 M Beattie $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Piprek,  xMole is ___InAlAs__ mole fraction!!!
#! MATERIAL: InAlGaAs_InP
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
#! VALIDITY: Only valid for T = 300.0 K
#! NOTES:
#! x=In mole fraction
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! Adachi - Properties of Semiconductor Alloys: Group-IV, III–V and II–VI Semiconductors, 2009
#! Experimental values and fit
#! Chi values from Ioffe
#! HISTORY:  
#! Created on 2019/07/11 Meghan Beattie - uOttawa SUNLAB

namespace eval InAlGaAs_InP::Bandgap {
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
        if {$::xMole == 0.205} {
            set Eg0 $::Eg
	} elseif {$::xMole == 0.748} {
	    set Eg0 1.288
	} elseif {$::xMole == 0.693} {
	    set Eg0 1.18
        } else {
            set Eg0 [expr {0.74 + 0.63*$::xMole + 0.12*$::xMole*$::xMole}]
        }
	
	set dEg0 0
        set Chi0 [expr {4.51 - 0.53*$::xMole}]
        set alpha [expr {4.00e-4 + 1.68e-4*$::xMole}]
        set beta [expr {145.2 + 157.6*$::xMole}]           

# Calculate Eg         
	set Eg [expr $Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)]
    
    	if {[info exists ::cbo]||[info exists ::VBO]} {
	    if {[info exists ::substrate]} {
		if {[info exists ::cbo]} {
        # For heterostructures, substrate and cbo are defined. Calculate new Chi0 for heterostructures                 
		    set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg0"]
		    set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi0"]
		    puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
		    set Chi0 [expr {$Chisubstrate - $::cbo*($Eg0 - $Egsubstrate)}]
		} elseif {[info exists ::VBO]} {
        # For heterostructures, substrate and VBO are defined. Calculate new Chi0 for heterostructures                 
		    set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg0"]
		    set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi0"]
		    puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
		    puts "VBO=$::VBO"
		    set deltaEg [expr {$Eg0-$Egsubstrate}]
		    set deltaEc [expr {$deltaEg+$::VBO}]
		    set Chi0 [expr {$Chisubstrate - $deltaEc}]
		}
	       
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
InAlGaAs_InP::Bandgap::init
