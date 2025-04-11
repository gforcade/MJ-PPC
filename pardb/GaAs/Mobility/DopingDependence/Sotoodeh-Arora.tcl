#----------------------------------------------------------------------#
# $Id: Sotoodeh-Arora.tcl,v 1.3 2007/12/04 09:16:44 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Sotoodeh
#! MATERIAL: GaAs
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Doping dependent mobility is calculated using
#! mu_dop = muminA + mudA/(1.+(N/N00)^AA),
#! where muminA=Ar_mumin*(T/T0)^Ar_alm; mudA = Ar_mud*(T/T0)^Ar_ald
#! N is net doping
#! N00=Ar_N0*(T/T0)^Ar_alN; AA = Ar_a*(T/T0)^Ar_ala
#! CALCULATED PARAMETER: 
#! mu_dop_n and mu_dop_p returns doping and temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: Arora model is used to implement Caughey-Thomas like model from Sotoodeh.
#! To use this model, activate doping dependent mobility model in sdevice command file.
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,
#! " Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! HISTORY:
#! Created on 2007/12/03 by Sameer Shah

namespace eval GaAs::DopingDependence {
    proc init {} {
	variable formula 2

# Parameters from Sotoodeh	
	set mumax_n 9400.0
	set mumax_p 491.5
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

# sdevice parameters (for Arora model) calculated from Sotoodeh parameters
	variable Ar_mumin_n $mumin_n
	variable Ar_mumin_p $mumin_p
	variable Ar_alm_n 0.0
	variable Ar_alm_p 0.0

	variable Ar_mud_n [expr {$mumax_n* pow(300.0/$::temp, $theta1_n)-$mumin_n}]
	variable Ar_mud_p [expr {$mumax_p* pow(300.0/$::temp, $theta1_p)-$mumin_p}]
	variable Ar_ald_n 0.0
	variable Ar_ald_p 0.0

       	variable Ar_N0_n $Nref_n
	variable Ar_N0_p $Nref_p
	variable Ar_alN_n $theta2_n
	variable Ar_alN_p $theta2_p

	variable Ar_a_n $lambda_n
	variable Ar_a_p $lambda_p
	variable Ar_ala_n 0.0
	variable Ar_ala_p 0.0
	
# Mobility calculation using Arora model and sdevice parameters
	set muminA_n [expr {$Ar_mumin_n*pow($::temp/300.0, $Ar_alm_n)}]
	set muminA_p [expr {$Ar_mumin_p*pow($::temp/300.0, $Ar_alm_p)}]
	set mudA_n [expr {$Ar_mud_n*pow($::temp/300.0, $Ar_ald_n)}]
	set mudA_p [expr {$Ar_mud_p*pow($::temp/300.0, $Ar_ald_p)}]
	set N00_n [expr {$Ar_N0_n*pow($::temp/300.0, $Ar_alN_n)}]
	set N00_p [expr {$Ar_N0_p*pow($::temp/300.0, $Ar_alN_p)}]
	set AA_n [expr {$Ar_a_n*pow($::temp/300.0, $Ar_ala_n)}]
	set AA_p [expr {$Ar_a_p*pow($::temp/300.0, $Ar_ala_p)}]

       	variable mu_dop_n 
	variable mu_dop_p
	set mu_dop_n [expr {$muminA_n + $mudA_n/(1.0 + pow(abs($::doping)/$N00_n,$AA_n))}]
	set mu_dop_p [expr {$muminA_p + $mudA_p/(1.0 + pow(abs($::doping)/$N00_p,$AA_p))}]
    }
    proc print {} {printPar::DopingDependenceAroraSection}    
}
GaAs::DopingDependence::init
