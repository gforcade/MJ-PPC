#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2008/04/09 14:28:45 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: Ge
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_constant_n and mu_constant_p returns mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: This is a temperature dependent and doping concentration independent model.
#! SDEVICE:
#! REFERENCE:
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003 

namespace eval Ge::ConstantMobility {
    proc init {} {
# Parameters from Piprek
	variable mumax_n 3.895e3
	variable mumax_p 2.505e2
	variable Exponent_n 1.67
	variable Exponent_p 2.33	;# Value from Default model is used since it is not specified in Piprek
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

# Mobility Calculation
	variable mu_const_n 
	variable mu_const_p
	
	set mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	set mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]
   }
    proc print {} {printPar::ConstantMobilitySection}    
}
Ge::ConstantMobility::init
