#----------------------------------------------------------------------#
# $Id: Palankovski.tcl,v 1.1 2008/06/27 14:43:56 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Palankovski
#! MATERIAL: InP
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
#! "Analysis and Simulation of Heterostructure Devices"
#! V. Palankovski, R. Quay, Springer-Verlag/Wien, 2004
#! http://www.iue.tuwien.ac.at/phd/palankovski/
#! HISTORY:
#! Created on 2008/06/27 by Sameer Shah

namespace eval InP::ConstantMobility {
    proc init {} {       
        # Parameters from Palankovski
        set muL300_n 5300.0
        set muL300_p 200.0
        set gamma0_n -1.9
        set gamma0_p -1.2
        
        # Parameters from sdevice
	variable mumax_n $muL300_n
	variable mumax_p $muL300_p
	variable Exponent_n [expr -$gamma0_n]
	variable Exponent_p [expr -$gamma0_p]
	variable mutunnel_n 0.05
	variable mutunnel_p 0.05

        # Mobility Calculation
	variable mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	variable mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]
    }
    proc print {} {printPar::ConstantMobilitySection}    
}
InP::ConstantMobility::init

