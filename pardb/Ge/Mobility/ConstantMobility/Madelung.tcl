#----------------------------------------------------------------------#
# $Id: Madelung.tcl,v 1.1 2008/04/09 14:28:44 sameers Exp $
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
#! The electron mobility model is valid for temperatures in the range 77-300 K
#! The hole mobility model is valid for temperatures in the range 100-300 K
#! NOTES: This is a temperature dependent and doping concentration independent model.
#! SDEVICE:
#! REFERENCE:
#! "Semiconductors:Data Handbook", O. Madelung, Springer, 2004

namespace eval Ge::ConstantMobility {
    proc init {} {
# Parameters from Reference
	set mu_n 4.9e7
	set mu_p 1.05e9
	variable Exponent_n 1.66
	variable Exponent_p 2.33	
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

	variable mumax_n [expr {$mu_n*pow(300,-$Exponent_n)}]
	variable mumax_p [expr {$mu_p*pow(300,-$Exponent_p)}]

# Mobility Calculation
	variable mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	variable mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]
   }
    proc print {} {printPar::ConstantMobilitySection}    
}
Ge::ConstantMobility::init
