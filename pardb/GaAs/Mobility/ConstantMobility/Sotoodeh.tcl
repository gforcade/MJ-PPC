#----------------------------------------------------------------------#
# $Id: Sotoodeh.tcl,v 1.3 2007/12/04 09:15:57 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Sotoodeh
#! MATERIAL: GaAs
#! PROPERTY: Constant Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_const_n and mu_const_p returns temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: This model is temperature dependent and doping concentration independent. 
#! The mobility value is the low doping mobility value from the doping dependent Sotoodeh model
#! SDEVICE:
#! REFERENCE: 
#! M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,
#! " Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! HISTORY:
#! Created on 2007/12/03 by Sameer Shah

namespace eval GaAs::ConstantMobility {
    proc init {} {
	# Parameters from Sotoodeh
	variable mumax_n 9400.0
	variable mumax_p 491.5
	variable Exponent_n 2.1
	variable Exponent_p 2.2
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

	# Mobility Calculation
	variable mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	variable mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]
   }
    proc print {} {printPar::ConstantMobilitySection}    
}
GaAs::ConstantMobility::init
