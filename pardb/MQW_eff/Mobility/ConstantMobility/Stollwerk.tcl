#----------------------------------------------------------------------#
# $Id: Stollwerk.tcl,v 1.2 2007/08/10 12:17:04 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Stollwerk
#! MATERIAL: GaAs
#! PROPERTY: Constant Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_constant_n and mu_constant_p returns mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: This model does not depend on doping concentration
#! SDEVICE:
#! REFERENCE: 
#! G. Stollwerck, Entwicklung eines hocheffizienten GaAs/GaSb Tandem Konzentrator Solarzellen Moduls, Dissertation, 
#! Albert-Ludwig-Universität und Fraunhofer ISE Freiburg (1998)


namespace eval GaAs::ConstantMobility {
    proc init {} {
# Parameters from Stollwerk
	variable mumax_n 9.337e3
	variable mumax_p 2.40e2
	variable Exponent_n 0.0
	variable Exponent_p 0.0
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
GaAs::ConstantMobility::init
