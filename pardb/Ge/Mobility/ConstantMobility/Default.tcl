#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/04/09 13:00:53 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: Ge
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_constant_n and mu_constant_p returns constant mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: This is a temperature dependent and doping concentration independent model.
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2008/04/09 by Sameer Shah

namespace eval Ge::ConstantMobility {
    proc init {} {
	variable mumax_n 3.9e3
	variable mumax_p 1.9e3
	variable Exponent_n 1.6
	variable Exponent_p 2.3
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

	# Mobility Calculation
	variable mu_const_n [expr $mumax_n*pow($::temp/300.0, -$Exponent_n)]
	variable mu_const_p [expr $mumax_p*pow($::temp/300.0, -$Exponent_p)]
   	}
	proc print {} {printPar::ConstantMobilitySection}  
}
Ge::ConstantMobility::init
