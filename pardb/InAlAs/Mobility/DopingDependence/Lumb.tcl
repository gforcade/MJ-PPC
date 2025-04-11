#----------------------------------------------------------------------#
# $Id: Lumb.tcl,v 1.1 2019/07/12 M Beattie $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model from Lumb, 
#! MATERIAL: InAlAs
#! PROPERTY: Mobility
#! EXPRESSION: 
#! Doping dependent mobility is calculated using
#! mu_dop = muminA + mudA/(1.+(N/N00)^AA),
#! where muminA=Ar_mumin*(T/T0)^Ar_alm; mudA = Ar_mud*(T/T0)^Ar_ald
#! N is net doping
#! N00=Ar_N0*(T/T0)^Ar_alN; AA = Ar_a*(T/T0)^Ar_ala
#! CALCULATED PARAMETER: 
#! mu_dop_n and mu_dop_p returns doping and temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY: Valid only at 300 K
#! This model is valid for Al mole fraction of 0.48. 
#! NOTES: Arora model is used to implement model from Lumb (Temperature independent, mumin = 0).
#! To use this model, activate doping dependent mobility model in sdevice command file.
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! M. Lumb, M. Yakes, M. Gonzalez, J.G. Tischler, and R.J. Walters, J. Appl. Phys., 114, 103504, 2013.
#! HISTORY:
#! Created on 2019/07/12 by Meghan Beattie

namespace eval InAlAs::DopingDependence {
    proc init {} {
	variable formula 2

# Parameters from Lumb	
	set mumax_n 1532.0
	set mumax_p 39.80
	set mumin_n 0
	set mumin_p 0
	set Nref_n 9.9e17
	set Nref_p 1.6e18
	set lambda_n 0.38
	set lambda_p 0.16
	set theta1_n 0
	set theta1_p 0
	set theta2_n 0
	set theta2_p 0

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
InAlAs::DopingDependence::init
