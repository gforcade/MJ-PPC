#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/04/09 14:28:45 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from sdevice
#! MATERIAL: Ge
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
#! NOTES: This model is temperature and doping concentration dependent. 
#! To use this model, activate doping dependent model in sdevice command file
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2008/04/09 by Sameer Shah

namespace eval Ge::DopingDependence {
    proc init {} {
	variable formula 2
	variable Ar_mumin_n 3.9e3
	variable Ar_mumin_p 1.9e3
	variable Ar_alm_n -1.6
	variable Ar_alm_p -2.3
	variable Ar_mud_n 0.0
	variable Ar_mud_p 0.0
	variable Ar_ald_n 0.0
	variable Ar_ald_p 0.0
	variable Ar_N0_n 1e17
	variable Ar_N0_p 1e17
	variable Ar_alN_n 0.0
	variable Ar_alN_p 0.0
	variable Ar_a_n 0.0
	variable Ar_a_p 0.0
	variable Ar_ala_n 0.0
	variable Ar_ala_p 0.0
	
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
Ge::DopingDependence::init
