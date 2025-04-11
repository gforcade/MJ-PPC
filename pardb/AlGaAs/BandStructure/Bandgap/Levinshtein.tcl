#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.3 2008/07/07 12:24:00 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Levinshtein
#! MATERIAL: AlGaAs
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
#! VALIDITY: this model is valid for T = 0 K to 1000 K
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2007/08/22 by Sameer Shah
#! Corrected the reference on 2008/07/07

namespace eval AlGaAs::Bandgap {
    proc init {} {
	    variable alpha 
    	variable beta 
	    variable Tpar 0.0
	    variable Eg0 
	    variable Chi0
	    variable Eg
	    variable Chi 	 
	    variable Bgn2Chi 0.5     
	    variable Egsubstrate 
	    variable Chisubstrate

# Calculate Eg0, Eg and define alpha and beta         
        # Parameters from Levinshtein
        variable Eg0_Gamma [expr {1.519 + 1.155*$::xMole + 0.37*$::xMole*$::xMole}]
        variable Eg0_X [expr {1.981 + 0.124*$::xMole + 0.144*$::xMole*$::xMole}]    
        variable Eg0_L [expr {1.815+0.69*$::xMole}]        
 
        set alpha_Gamma 5.41e-4
        set alpha_X 4.6e-4
        set alpha_L 6.05e-4

        set beta 204.0

        # Calculate Eg0 and alpha
        set Eg0list [list $Eg0_Gamma $Eg0_X $Eg0_L]
        set alphalist [list $alpha_Gamma $alpha_X $alpha_L]
        set Eg0_minIndex [minIndex $Eg0list]
        set Eg0 [lindex $Eg0_minIndex 0]            ;# The minima of all three bandgaps
        set bandIndex [lindex $Eg0_minIndex 1]
        set alpha [lindex $alphalist $bandIndex]

        # Calculate Eg
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
            # In Levinshtein, Chi is defined for T=300K. Let this value be Chi300. 
            if {$::xMole < 0.45} {
                set Chi300 [expr {4.07 - 1.1*$::xMole}]
            } else {
                set Chi300 [expr {3.64 - 0.14*$::xMole}]
            }
            # Calculate Chi0 using Chi300
   	        set Chi0 [expr {$Chi300 - $alpha*300.0*300.0/(2*(300.0 + $beta))} ]
            # Calculate Chi
            set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
        }	
    }
    proc print {} {printPar::BandgapSection}    
}
AlGaAs::Bandgap::init
