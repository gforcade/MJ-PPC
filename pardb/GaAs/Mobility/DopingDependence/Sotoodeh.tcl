#----------------------------------------------------------------------#
# $Id: Sotoodeh.tcl,v 1.0 2012/01/22 arbez Exp $
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
#! To use this model, activate doping dependent mobility model in sdevice command file.
#! SDEVICE: Mobility(DopingDependence(Sotoodeh))
#! REFERENCE: 
#! M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,
#! " Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! HISTORY:
#! Created on 2012/01/02 by Gilbert Arbez

namespace eval GaAs::DopingDependence {
    proc init {} {

# Parameters from Sotoodeh	
	variable mumax_n 9400.0
	variable mumax_p 491.5
	variable mumin_n 500.0
	variable mumin_p 20.0
	variable nref_n 6.0e16
	variable nref_p 1.48e17
	variable theta1_n 2.1
	variable theta1_p 2.2
	variable theta2_n 3.0
	variable theta2_p 3.1
	variable lambda_n 0.394
	variable lambda_p 0.38

       	variable mu_dop_n 
	variable mu_dop_p
	set mu_dop_n [expr {$mumin_n + ($mumax_n*pow((300/$::temp),$theta1_n) - $mumin_n) / (1 + pow(abs($::doping)/($nref_n*pow(($::temp/300),$theta2_n)),$lambda_n))}]
	set mu_dop_p [expr {$mumin_p + ($mumax_p*pow((300/$::temp),$theta1_p) - $mumin_p) / (1 + pow(abs($::doping)/($nref_p*pow(($::temp/300),$theta2_p)),$lambda_p))}]
    }
    proc print {} {printPar::DopingDependenceSotoodehSection}    
}
GaAs::DopingDependence::init
