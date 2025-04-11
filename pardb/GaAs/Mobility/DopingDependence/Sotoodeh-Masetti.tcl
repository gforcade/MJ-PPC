#----------------------------------------------------------------------#
# $Id: Sotoodeh-Masetti.tcl,v 1.3 2007/12/04 09:16:44 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Sotoodeh
#! MATERIAL: GaAs
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
#! To use this model, activate doping dependent model in sdevice command file and initialize Sotoodeh model in GaAs.tcl
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,
#! " Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! HISTORY:
#! Created on 2007/12/03 by Sameer Shah

namespace eval GaAs::DopingDependence {
    proc init {} {
	variable formula 1

# Parameters from Sotoodeh	
	variable mumax_n 9400.0
	variable mumax_p 491.5
	set mumin_n 500.0
	set mumin_p 20.0
	set Nref_n 6.0e16
	set Nref_p 1.48e17
	set lambda_n 0.394
	set lambda_p 0.38
	set theta1_n 2.1
	set theta1_p 2.2
	set theta2_n 3.0
	set theta2_p 3.0

# sdevice parameters (for Masetti model) calculated from Sotoodeh parameters
	variable mumin1_n $mumin_n
	variable mumin1_p $mumin_p
	variable mumin2_n $mumin_n
	variable mumin2_p $mumin_p
	variable mu1_n 0.0
	variable mu1_p 0.0
	variable Pc_n 0.0
	variable Pc_p 0.0
	variable Cr_n [expr {$Nref_n*pow($::temp/300.0, $theta2_n)}]
	variable Cr_p [expr {$Nref_p*pow($::temp/300.0,$theta2_p)}]
	variable Cs_n 0.0
	variable Cs_p 0.0
	variable alpha_n $lambda_n
	variable alpha_p $lambda_p
	variable beta_n 0.0
	variable beta_p 0.0

# Constant mobility calculation using Constant mobility model and sdevice parameters
	variable Exponent_n $theta1_n
	variable Exponent_p $theta1_p
	variable mutunnel_n 0.05 ;# default parameter from sdevice
	variable mutunnel_p 0.05 ;# default parameter from sdevice

	variable mu_const_n 
	variable mu_const_p
	
	set mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	set mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]
  	
# Doping dependent Mobility calculation using Masetti model and sdevice parameters
	variable mu_dop_n 
	variable mu_dop_p
	set mu_dop_n [expr {$mumin1_n*exp(-$Pc_n/abs($::doping)) + ($mu_const_n - $mumin2_n)/(1.0+ pow(abs($::doping)/$Cr_n, $alpha_n)) - $mu1_n/(1.0+ pow($Cs_n/abs($::doping),$beta_n))}]
	set mu_dop_p [expr {$mumin1_p*exp(-$Pc_p/abs($::doping)) + ($mu_const_p - $mumin2_p)/(1.0+ pow(abs($::doping)/$Cr_p, $alpha_p)) - $mu1_p/(1.0+ pow($Cs_p/abs($::doping),$beta_p))}]
   }
    proc print {} {printPar::DopingDependenceMasettiSection}    
}
GaAs::DopingDependence::init
