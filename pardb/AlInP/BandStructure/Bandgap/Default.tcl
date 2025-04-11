#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/07/28 10:20:29 sameers Exp $
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
#! This model is valid at room temperature for x=0.5
#! NOTES:
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! Gergoe's Material Parameter Database
#! HISTORY:  
#! Created on 2008/07/28 by Sameer Shah

namespace eval AlInP::Bandgap {
    proc init {} {        
	variable alpha 0.0
    	variable beta 0
	variable Tpar 0.0
	variable Eg0 2.39
	variable Chi0 3.78
#        variable Chi0 4.0
	variable Eg
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egsubstrate 
	variable Chisubstrate

# Calculate Eg(x,T)
	set Eg $Eg0     
  
	        set Chi $Chi0
}
    proc print {} {printPar::BandgapSection}    
}
AlInP::Bandgap::init
