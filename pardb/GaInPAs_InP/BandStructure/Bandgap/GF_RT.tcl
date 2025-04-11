#----------------------------------------------------------------------#
# $Id: MB.tcl, 2021/11/16 G Forcade $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Piprek,  xMole is ___InP__ mole fraction!!!
#! MATERIAL: GaInPAs_InP
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
#! Adachi - Chap 30. III-V Ternary and Quaternary compounds, 2017 + Adachi - Properties of semiconductors 2009 
#! Chose bowing parameter to reach 1.344eV, being the bandgap of InP.
#! Chi value from  Vurgaftman - "Band parameters for III-V compound semiconductors and their alloys" 2001. 
#! Linear interpolation between the ternary and binary is great to calculate Chi0
#! HISTORY:  
#! Created on 2021/11/16 Gavin Forcade - uOttawa SUNLAB

namespace eval GaInPAs_InP::Bandgap {
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

	## calculates the bandgap assuming varshni 
	proc Eg_Calc { Eg0 alpha beta T } {
		return [expr $Eg0 - $alpha*$T*$T/($T + $beta)]
	}	


## InAs params. Vurgaftmann
   	set alpha_InAs 0.000276
	set beta_InAs 93.0
	set Eg0_InAs 0.417

## GaAs params. Vurgaftmann
   	set alpha_GaAs 0.0005404
	set beta_GaAs 204.0
	set Eg0_GaAs 1.519

## InP params. Vurgaftmann
   	set alpha_InP 0.000363
	set beta_InP 162.0
	set Eg0_InP 1.4236


## Bowing parameters. Vurgaftmann
	set C_InGaAs 0.477
	set C_InGaAsP 0.13

## In0.53Ga0.47As bandgap. 0.737eV and 300K
	set Eg_InGaAs [expr {[Eg_Calc $Eg0_InAs $alpha_InAs $beta_InAs $::temp]*0.53 + [Eg_Calc $Eg0_GaAs $alpha_GaAs $beta_GaAs $::temp]*0.47 - 0.47*0.53*$C_InGaAs }]

	

# Calculate Chi0, Eg0 and define alpha,beta
###        set Eg0 [expr {0.7359 + 0.483622*$::xMole + 0.134*$::xMole*$::xMole}]  ### old and bad bandgap calculation
### below is same as set Eg0 [expr {1.353 * $::xMole + 0.737 * (1.0 - $::xMole) - 0.13*(1.0 - $::xMole)*$::xMole}] at room temperature
### 2024/09/12        set Eg0 [expr { $Eg_InGaAs * (1.0 - $::xMole) + [Eg_Calc $Eg0_InP $alpha_InP $beta_InP $::temp]*$::xMole - 0.13*(1.0 - $::xMole)*$::xMole }]
	set Eg0 [expr { $Eg_InGaAs * (1.0 - $::xMole) + [Eg_Calc $Eg0_InP $alpha_InP $beta_InP $::temp]*$::xMole - 0.26*(1.0 - $::xMole)*$::xMole }]

	
	set dEg0 0
        set Chi0 [expr {4.51 - 0.53*$::xMole}]
        set alpha 0.0
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
	set Chi0 [expr {4.629 - 0.249*$::xMole}]        
	set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
    }
    proc print {} {printPar::BandgapSection}    
}
GaInPAs_InP::Bandgap::init
