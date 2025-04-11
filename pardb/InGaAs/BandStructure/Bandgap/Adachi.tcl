#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2022/01/15 16:24:34 Gavin Forcade Exp $
#----------------------------------------------------------------------#
#! MODEL:  mole fraction dependent model from Adachi
#! MATERIAL: InGaAs
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
#! x=Ga mole fraction
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! Adachi, 2009
#! HISTORY:  
#! Created on 2022/01/15 by Gavin Forcade

namespace eval InGaAs::Bandgap {
    proc init {} {        
	variable alpha 
    	variable beta 
	variable Tpar 300.0
	variable Eg0 
	variable Chi0
	variable Eg
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egsubstrate 
	variable Chisubstrate

# Calculate Eg0(x), alpha(x) and beta(x)         
        # Parameters from Adachi
        set Eg0_InAs 0.359
        set alpha_InAs 2.76e-04
        set beta_InAs 93.0        
         
        set Eg0_GaAs 1.43
        set alpha_GaAs 5.405e-04
        set beta_GaAs 204.0
                                    
        set K_Eg0 0.58
        set K_alpha 0.0  ;# Since no value is listed in Piprek, linear variation is assumed
        set K_beta 0.0
        
        # Calculate the band gaps for InGaAs at T=0K    
        variable Eg0 [expr {[::compute_ternary $::xMole $Eg0_GaAs $Eg0_InAs $K_Eg0]}]
        variable alpha [expr {[::compute_ternary $::xMole $alpha_GaAs $alpha_InAs $K_alpha]}]
        variable beta [expr {[::compute_ternary $::xMole $beta_GaAs $beta_InAs $K_beta]}]
 
# Calculate Eg(x,T)
	set Eg [expr $Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)]    
  
# Calculate Chi0 and Chi for heterostructure/bulk        
	if {[info exists ::cbo] || [info exists ::VBO]} {
            if {[info exists ::substrate]} {
                if {[info exists ::cbo]} {  
		# For heterostructures, substrate and cbo are defined. Calculate Chi and Chi0 for heterostructures                 
	            set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
	            set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
	            puts stderr "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
	            set Chi [expr {$Chisubstrate - $::cbo*($Eg - $Egsubstrate)}]
	            set Chi0 [expr {$Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
	        } elseif {[info exists ::VBO]} {
		# For heterostructures, substrate and VBO are defined. Calculate Chi and Chi0 for heterostructures     
		    set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
		    set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
		    puts stderr "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate Eg: $Eg"
		    set deltaEg [expr {$Eg-$Egsubstrate}]
		    set deltaEc [expr {$deltaEg + $::VBO}]
		    set Chi [expr {$Chisubstrate-$deltaEc}]
		    puts stderr "deltaEg: $deltaEg deltaEc: $deltaEc Chi: $Chi VBO: $::VBO"
		    # Calculate Chi
	    	    set Chi0 [expr {$Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
		    puts stderr "Chi0: $Chi0 Tpar: $Tpar temp: $::temp"
	        }    
            } else {
		puts stderr "Please specify the substrate material to calculate Chi according to cbo."
                exit -1    
            }
        } else {    
        # Calculate Chi for bulk              
            # In Piprek, Chi is defined for T=300K. Let this value be Chi300. 
            set Chi300 [expr {4.9-0.83*$::xMole}];   #linear interpolation between electron affinity values of GaAs and InAs is assumed
            # Calculate Chi0 using Chi300
   	    set Chi0 [expr {$Chi300 - $alpha*300.0*300.0/(2*(300.0 + $beta))} ]
            # Calculate Chi
	    set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
        }
    }
    proc print {} {printPar::BandgapSection}    
}
InGaAs::Bandgap::init
