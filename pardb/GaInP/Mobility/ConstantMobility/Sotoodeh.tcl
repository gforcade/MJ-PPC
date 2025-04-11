#----------------------------------------------------------------------#
# $Id: Sotoodeh.tcl,v 1.2 2008/07/07 12:29:59 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Sotoodeh
#! MATERIAL: GaInP
#! PROPERTY: Constant Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_const_n and mu_const_p returns temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY:
#! This model is valid for x=0.51
#! NOTES: This model is temperature dependent and doping concentration independent. 
#! The mobility value is the low doping mobility value from the doping dependent Sotoodeh model
#! SDEVICE:
#! REFERENCE: 
#! M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,"
#! Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! HISTORY:
#! Created on 2008/07/07 by Sameer Shah

namespace eval GaInP::ConstantMobility {
    proc init {} {
	# Parameters from Sotoodeh
	variable mumax_n 500.0
	variable mumax_p 30.0
	set theta1_n 1.66
	set theta1_p 2.0        
        
        # sdevice parameters calculated from Sotoodeh parameters
	variable Exponent_n $theta1_n
	variable Exponent_p $theta1_p
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

	# Mobility Calculation
	variable mu_const_n 500
	variable mu_const_p 30
   }
    proc print {} {printPar::ConstantMobilitySection}    
}
GaInP::ConstantMobility::init
