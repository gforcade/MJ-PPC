#----------------------------------------------------------------------#
# $Id: Default.tcl, 2019/07/11 M Beattie $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Piprek,  xMole is ___In__ mole fraction!!!
#! MATERIAL: InAlAs
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
#! Chi values from Ioffe
#! HISTORY:  
#! Created on 2019/07/11 Meghan Beattie - uOttawa SUNLAB

namespace eval InAlAs::Bandgap {
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

	set xMole_r [expr 1.0 - $::xMole]

# Calculate Chi0, Eg0 and define alpha,beta
        if {$xMole_r < 0.63} {
            set Chi0 [expr {4.9 - 1.93*$xMole_r}]
            set Eg0 [expr {0.359 + 1.931*$xMole_r + 0.720*$xMole_r*$xMole_r}]
        } else {
            set Chi0 [expr {3.89 - 0.78*$xMole_r + 0.720*$xMole_r*$xMole_r}]
            set Eg0 [expr {1.37 + 0.78*$xMole_r}]
            set alpha 0
        }
        set alpha [expr {2.76e-4 + 6.09e-4*$xMole_r}]
        set beta [expr {93.0 + 437.0*$xMole_r}]           

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
InAlAs::Bandgap::init
