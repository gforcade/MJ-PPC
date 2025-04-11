#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.3 2008/07/15 10:44:40 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Piprek
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
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:  
#! Created on 2007/08/27 by Sameer Shah
#! 2008/07/15: Updated Chi300 so that Chi values are consistent with those of AlAs and GaAs 

namespace eval AlGaAs::Bandgap {
    proc init {} {
puts stderr "gadebug: at start of init"
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

# Calculate Eg0(x), alpha(x) and beta(x)         
        # Parameters from Piprek
        set Eg0_Gamma_GaAs 1.519
        set Eg0_X_GaAs 1.981
        set Eg0_L_GaAs 1.815
        set alpha_Gamma_GaAs 5.405e-04
        set beta_Gamma_GaAs 204.0
        set alpha_X_GaAs 4.6e-4
        set beta_X_GaAs 204.0
        set alpha_L_GaAs 6.05e-4
        set beta_L_GaAs 204.0        
        
        set Eg0_Gamma_AlAs 3.099
        set Eg0_X_AlAs 2.24
        set Eg0_L_AlAs 2.46
        set alpha_Gamma_AlAs 8.85e-04
        set beta_Gamma_AlAs 530.0        
        set alpha_X_AlAs 7.0e-04
        set beta_X_AlAs 530.0
        set alpha_L_AlAs 6.05e-4                
        set beta_L_AlAs 204.0
                                       
        set K_Gamma [expr {-0.127+1.31*$::xMole}]
        set K_X 0.055
        set K_L 0.0
        
        set K_alpha 0.0  ;# Since no value is listed in Piprek, linear variation is assumed
        set K_beta 0.0
        
        # Calculate the band gaps for AlGaAs at T=0K    
        variable Eg0_Gamma [expr {[::compute_ternary $::xMole $Eg0_Gamma_AlAs $Eg0_Gamma_GaAs $K_Gamma]}]
        variable Eg0_X [expr {[::compute_ternary $::xMole $Eg0_X_AlAs $Eg0_X_GaAs $K_X]}]
        variable Eg0_L [expr {[::compute_ternary $::xMole $Eg0_L_AlAs $Eg0_L_GaAs $K_L]}]

        set alpha_Gamma [expr {[::compute_ternary $::xMole $alpha_Gamma_AlAs $alpha_Gamma_GaAs $K_alpha]}]
        set alpha_X [expr {[::compute_ternary $::xMole $alpha_X_AlAs $alpha_X_GaAs $K_alpha]}]
        set alpha_L [expr {[::compute_ternary $::xMole $alpha_L_AlAs $alpha_L_GaAs $K_alpha]}]
        set beta_Gamma [expr {[::compute_ternary $::xMole $beta_Gamma_AlAs $beta_Gamma_GaAs $K_beta]}]
        set beta_X [expr {[::compute_ternary $::xMole $beta_X_AlAs $beta_X_GaAs $K_beta]}]
        set beta_L [expr {[::compute_ternary $::xMole $beta_L_AlAs $beta_L_GaAs $K_beta]}]

        # Calculate Eg0(x),alpha(x) and beta(x)
        set Eg0list [list $Eg0_Gamma $Eg0_X $Eg0_L]
        set alphalist [list $alpha_Gamma $alpha_X $alpha_L]
        set betalist [list $beta_Gamma $beta_X $beta_L]
    
        set Eg0_minIndex [minIndex $Eg0list]
        set Eg0 [lindex $Eg0_minIndex 0]            ;# The minima of all three bandgaps
        set bandIndex [lindex $Eg0_minIndex 1]
        set alpha [lindex $alphalist $bandIndex]
        set beta [lindex $betalist $bandIndex]

# Calculate Eg(x,T)
	set Eg [expr $Eg0 + $alpha*$Tpar*$Tpar/($Tpar + $beta) - $alpha*$::temp*$::temp/($::temp + $beta)]    
  
# Calculate Chi0 and Chi         
	if {[info exists ::cbo]||[info exists ::VBO]} {
            if {[info exists ::substrate]} {
		if {[info exists ::cbo]} {
        # For heterostructures, substrate and cbo are defined. Calculate Chi for heterostructures                 
		    set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
		    set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
		    puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
		    set Chi [expr {$Chisubstrate - $::cbo*($Eg - $Egsubstrate)}]
		    set Chi0 [expr {$Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
		} elseif {[info exists ::VBO]} {		
        # For heterostructures, substrate and VBO are defined. Calculate new Chi0 for heterostructures                 
		    set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
		    set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
		    puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
		    set deltaEg [expr {$Eg-$Egsubstrate}]
		    set deltaEc [expr {$deltaEg+$::VBO}]
		    set Chi [expr {$Chisubstrate - $deltaEc}]
		    set Chi0 [expr {$Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
		}		
            } else {
                puts stderr "Please specify the substrate material to calculate Chi according to cbo."
                exit -1    
            }
        } else {    
        # Calculate Chi for bulk
            if 0 {
            # Use sdevice default parameters
            if {$::xMole < 0.45} {
                set Chi0 [expr {4.11826-1.20724*$::xMole}]              
            } else {
                set Chi0 [expr {3.5873 - 0.02727*$::xMole}]
            }    
            # Calculate Chi
            set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
            }
            # In Piprek, Chi is defined for T=300K. Let this value be Chi300. 
            set Chi300 [expr {4.07-0.22*$::xMole}];   #linear interpolation between electron affinity values of AlAs and GaAs is assumed
            # Calculate Chi0 using Chi300
   	    set Chi0 [expr {$Chi300 - $alpha*300.0*300.0/(2*(300.0 + $beta))} ]
            # Calculate Chi
	    set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
        }
    }
    proc print {} {printPar::BandgapSection}    
}
AlGaAs::Bandgap::init
