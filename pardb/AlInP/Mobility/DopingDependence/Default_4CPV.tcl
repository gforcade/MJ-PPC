#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.2 2008/07/07 11:47:32 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Sotoodeh
#! MATERIAL: AlInP
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Doping dependent mobility is calculated using
#! mu_dop = mumin1 exp(-Pc/N) + (mu_const - mumin2)/(1+(N/Cr)^alpha) - mu1/(1+(Cs/N)^beta)
#! with mu_const from ConstantMobility
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_dop_n and mu_dop_p returns temperature and doping dependent mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: Masetti model is used to implement Caughey-Thomas like model from Sotoodeh. 
#! To use this model, activate doping dependent model in sdevice command file and initialize Sotoodeh model in AlInP.tcl
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! Gergoe's Material Parameter Database
#! HISTORY:
#! Created on 2008/07/07 by Sameer Shah

namespace eval AlInP::DopingDependence {
    proc init {} {
	variable formula 1

# sdevice parameters 
	variable mumin1_n 0.0
	variable mumin1_p 0.0
	variable mumin2_n 0.0
	variable mumin2_p 0.0
	variable mu1_n 0.0
	variable mu1_p 0.0
	variable Pc_n 0.0
	variable Pc_p 0.0
	variable Cr_n 5e17
	variable Cr_p 2.75e17
	variable Cs_n 0.0
	variable Cs_p 0.0
	variable alpha_n 0.436
	variable alpha_p 0.397
	variable beta_n 0.0
	variable beta_p 0.0

# Constant mobility calculation using Constant mobility model and sdevice parameters
#	variable mumax_n 150
	variable mumax_n $::AlInP::ConstantMobility::mumax_n
#	variable mumax_p 180
	variable mumax_p $::AlInP::ConstantMobility::mumax_p
	variable Exponent_n 1
	variable Exponent_p 1
	variable mutunnel_n 0.05 ;# default parameter from sdevice
	variable mutunnel_p 0.05 ;# default parameter from sdevice

	variable mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	variable mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]
	 	
# Doping dependent Mobility calculation using Masetti model and sdevice parameters
	variable mu_dop_n [expr {$mumin1_n*exp(-$Pc_n/abs($::doping)) + ($mu_const_n - $mumin2_n)/(1.0+ pow(abs($::doping)/$Cr_n, $alpha_n)) - $mu1_n/(1.0+ pow($Cs_n/abs($::doping),$beta_n))}]
	variable mu_dop_p [expr {$mumin1_p*exp(-$Pc_p/abs($::doping)) + ($mu_const_p - $mumin2_p)/(1.0+ pow(abs($::doping)/$Cr_p, $alpha_p)) - $mu1_p/(1.0+ pow($Cs_p/abs($::doping),$beta_p))}]

   }
    proc print {} {printPar::DopingDependenceMasettiSection}    
}
AlInP::DopingDependence::init
