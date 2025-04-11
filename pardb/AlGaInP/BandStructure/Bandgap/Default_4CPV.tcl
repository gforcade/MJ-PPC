#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.3 2008/07/15 10:44:40 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Piprek
#! MATERIAL: AlGaInP
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
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 
#! in the calculation of the parameter Bandgap::Chi.
#! SDEVICE:
#! REFERENCE: 
#! Vurgaftman et al. J. Appl. Phys., Vol 89, No 11, June 2001.
#! HISTORY:  
#! Created on 2010/11/25 by Alex Walker
#! modified 2015/07/20 M Wilkins

namespace eval AlGaInP::Bandgap {
    proc init {} {        
	variable alpha 0.
    	variable beta 0.
	variable Tpar 300.0
	variable Chi0 3.43
	variable Eg
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egsubstrate 
	variable Chisubstrate

    	variable Eg0 2.3 ;# 4CPV value

    }
    proc print {} {printPar::BandgapSection}    
}
AlGaInP::Bandgap::init
