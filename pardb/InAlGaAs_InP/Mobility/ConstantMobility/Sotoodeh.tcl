#----------------------------------------------------------------------#
# $Id: Sotoodeh.tcl,v 1.1 2008/09/24 21:28:12 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Sotoodeh
#! MATERIAL: InGaAs
#! PROPERTY: Constant Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_const_n and mu_const_p returns temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY:
#! This model is valid for Ga mole fraction of 0.47. 
#! NOTES: This model is temperature dependent and doping concentration independent. 
#! The mobility value is the low doping mobility value from the doping dependent Sotoodeh model
#! SDEVICE:
#! REFERENCE: 
#! M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,"
#! Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! HISTORY:
#! Created on 2008/09/24 by Sameer Shah

namespace eval InAlGaAs_InP::ConstantMobility {
    proc init {} {
	# Parameters from Sotoodeh
	variable mumax_n 14000.0
	variable mumax_p 320.0
	set theta1_n 1.59
	set theta1_p 1.59        
        
        # sdevice parameters calculated from Sotoodeh parameters
	variable Exponent_n $theta1_n
	variable Exponent_p $theta1_p
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

	# Mobility Calculation
	variable mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	variable mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]	
   }
    proc print {} {printPar::ConstantMobilitySection}    
}
InAlGaAs_InP::ConstantMobility::init
