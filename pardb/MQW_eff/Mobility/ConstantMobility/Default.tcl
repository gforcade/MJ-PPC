#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.3 2007/12/04 09:16:44 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_const_n and mu_const_p returns mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: This model does not depend on doping concentration
#! SDEVICE:
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2007/12/03 by Sameer Shah

namespace eval MQW_eff::ConstantMobility {
    proc init {} {
# Parameters from sdevice
	variable mumax_n 0.28
	variable mumax_p 0.28
	variable Exponent_n 0.0
	variable Exponent_p 0.0
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

# Mobility Calculation
	variable mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	variable mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]
   }
    proc print {} {printPar::ConstantMobilitySection}    
}
MQW_eff::ConstantMobility::init
