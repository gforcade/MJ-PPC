#----------------------------------------------------------------------#
# $Id: Lumb.tcl,v 1.1 2019/07/12 M Beattie $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Sotoodeh
#! MATERIAL: InAlAs
#! PROPERTY: Constant Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_const_n and mu_const_p returns temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY: Valid only at 300 K
#! This model is valid for Al mole fraction of 0.48. 
#! NOTES: This model is temperature dependent and doping concentration independent. 
#! The mobility value is the low doping mobility value from the doping dependent Lumb model
#! SDEVICE:
#! REFERENCE: 
#! M. Lumb, M. Yakes, M. Gonzalez, J.G. Tischler, and R.J. Walters, J. Appl. Phys., 114, 103504, 2013.
#! HISTORY:
#! Created on 2019/07/12 by Meghan Beattie

namespace eval InAlAs::ConstantMobility {
    proc init {} {
	# Parameters from Sotoodeh
	variable mumax_n 1532.0
	variable mumax_p 39.8
	set theta1_n 0
	set theta1_p 0     
        
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
InAlAs::ConstantMobility::init
