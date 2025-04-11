#----------------------------------------------------------------------#
# $Id: EMIS.tcl,v 1.2 2007/08/10 12:17:02 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent Bose-Einstein model from EMIS
#! MATERIAL: GaAs
#! PROPERTY: Bandgap
#! EXPRESSION: 
#! Temperature dependent Bandgap is calculated using
#!	Eg(T) = EB - aB*(1+2/{exp(theta/T)-1})   
#! where,
#!	 Eg(T) =  Bandgap [eV] at temperature, T [K]  
#!        EB       is a parameter [eV]
#!        aB       represents  strength of the electron-phonon interaction [eV]
#!        theta    corresponds to average phonon frequency [K]
#! Temperature dependent electron affinity is calculated using 
#! Chi(T) = Chi(Tpar)- alpha*Tpar^2/(Tpar + beta) + alpha*T^2/(2*(T + beta)) + Bgn2Chi*Ebgn
#! Ebgn   =  Bandgap narrowing [eV] depending on BGN model not set here!
#! CALCULATED PARAMETER: 
#! Eg returns Eg(T) [eV]
#! Chi returns Chi(T) with Ebgn = 0 [eV]
#! VALIDITY: 
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 in the calculation of the parameter Bandgap::Chi.
#! The value of Chi0 is the sdevice default value.
#! SDEVICE:
#! REFERENCE: 
#! "Properties of GaAs: 3rd Edition", M R Brozel and G E Stillman (Eds.), IEE/Inspec EM-016, 1996
#! HISTORY:
#! Created on 07/06/2007 by Sameer Shah
#! PENDING: 
#! 1) Implement proper handling of Chi(T) dependence. 
#! 2) Check cbo calculation

namespace eval GaAs::Bandgap {
    proc init {} {
# parameters from Bose-Einstein model
	set EB 1.571
	set aB 5.70e-02
	set theta 240.00   

# calculate sdevice parameters for Bandgap section
	variable alpha 0.0   ;# Suppress T dependence of Eg in sdevice default model for Bandgap
	variable beta 1e-5   ;# Since Tpar=0, beta is set to a very small value to avoid divide by zero error in Chi(T) calculations
	variable Tpar 0.0
	variable Eg0
	set Eg0 [expr $EB - $aB*(1+2/(exp($theta/$::temp)-1))]
	variable Eg $Eg0

	variable Chi0
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egsubstrate 
	variable Chisubstrate

# Calculate Chi using the default model
	set alpha1 5.4050e-04
	set beta1 2.0400e+02
# calculate new value of chi if substrate exists.
      	if {[info exists ::cbo]} {
	    set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
	    set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
	    puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
	    set Chi [expr $Chisubstrate - $::cbo*($Eg - $Egsubstrate)]
	    set Chi0 [expr $Chi + $alpha1*$Tpar*$Tpar/(2*($Tpar + $beta1)) - $alpha1*$::temp*$::temp/(2*($::temp + $beta1))]
	} else {
	    variable Chi0 4.07
	    set Chi [expr $Chi0 - $alpha1*$Tpar*$Tpar/(2*($Tpar + $beta1)) + $alpha1*$::temp*$::temp/(2*($::temp + $beta1))]	  
	}		   	
    }
    proc print {} {printPar::BandgapSection}    
}
GaAs::Bandgap::init
