#----------------------------------------------------------------------#
# $Id: Stollwerk-Masetti.tcl,v 1.3 2007/12/04 09:16:44 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Stollwerwk
#! MATERIAL: GaAs
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Doping dependent mobility is calculated using
#! mu_dop = mumin1 exp(-Pc/N) + (mu_const - mumin2)/(1+(N/Cr)^alpha) - mu1/(1+(Cs/N)^beta)
#! with mu_const from ConstantMobility
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_dop_n and mu_dop_p returns doping and temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES:  
#! To use this model, activate doping dependent model in sdevice command file and initialize Sotoodeh-Constant model in GaAs.tcl
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! G. Stollwerck, Entwicklung eines hocheffizienten GaAs/GaSb Tandem Konzentrator Solarzellen Moduls, Dissertation, 
#! Albert-Ludwig-Universität und Fraunhofer ISE Freiburg (1998)
#! HISTORY:
#! Created on 2007/12/03 by Sameer Shah

namespace eval GaAs::DopingDependence {
    proc init {} {
	variable formula 1

# Parameters from Stollwerk
	variable mumin1_n 322.0
	variable mumin1_p 7.5
	variable mumin2_n 322.0
	variable mumin2_p 7.5
	variable mu1_n 0.0
	variable mu1_p 0.0
	variable Pc_n 0.0
	variable Pc_p 0.0
	variable Cr_n 4.0e16
	variable Cr_p 6.25e17
	variable Cs_n 0.0
	variable Cs_p 0.0
	variable alpha_n 0.41
	variable alpha_p 0.397
	variable beta_n 0.0
	variable beta_p 0.0

# Constant mobility calculation using Constant mobility model and parameters from Stollwerk
	variable mumax_n 9337.0
	variable mumax_p 240.0
	variable Exponent_n 0
	variable Exponent_p 0
	variable mutunnel_n 0.05 ;# default parameter from sdevice
	variable mutunnel_p 0.05 ;# default parameter from sdevice

	variable mu_const_n 
	variable mu_const_p
	
	set mu_const_n [expr $mumax_n*pow($::temp/300.0, -$Exponent_n)]
	set mu_const_p [expr $mumax_p*pow($::temp/300.0, -$Exponent_p)]
  	
# Doping dependent Mobility calculation using Masetti model and parameters from Stollwerk
	variable mu_dop_n 
	variable mu_dop_p
	set mu_dop_n [expr {$mumin1_n*exp(-$Pc_n/abs($::doping)) + ($mu_const_n - $mumin2_n)/(1.0+ pow(abs($::doping)/$Cr_n, $alpha_n)) - $mu1_n/(1.0+ pow($Cs_n/abs($::doping),$beta_n))}]
	set mu_dop_p [expr {$mumin1_p*exp(-$Pc_p/abs($::doping)) + ($mu_const_p - $mumin2_p)/(1.0+ pow(abs($::doping)/$Cr_p, $alpha_p)) - $mu1_p/(1.0+ pow($Cs_p/abs($::doping),$beta_p))}]
   }
    proc print {} {printPar::DopingDependenceMasettiSection}    
}
GaAs::DopingDependence::init
