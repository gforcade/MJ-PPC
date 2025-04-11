#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/07/07 11:42:40 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: AlInP
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_constant_n and mu_constant_p returns constant mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: This is a temperature dependent and doping concentration independent model.
#! REFERENCE: 
#! Gergoe's Material Parameter Database
#! HISTORY:
#! Created on 2008/07/07 by Sameer Shah

namespace eval AlInP::ConstantMobility {
    proc init {} {
	variable mumax_n 100
	variable mumax_p 10
	variable Exponent_n 1.0
	variable Exponent_p 1.0
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

	# Mobility Calculation
	variable mu_const_n 100
	variable mu_const_p 10
   	}
	proc print {} {printPar::ConstantMobilitySection}  
}
AlInP::ConstantMobility::init
