#----------------------------------------------------------------------#
# $Id: Default-Arora.tcl,v 1.3 2007/12/04 09:16:44 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from sdevice
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
#! NOTES: This model is temperature and doping concentration dependent. 
#! To use this model, activate doping dependent model in sdevice command file
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2007/12/03 by Sameer Shah

namespace eval GaAs::DopingDependence {
    proc init {} {
	variable formula 2
	variable Ar_mumin_n 2.1360e+03
	variable Ar_mumin_p 21.48
	variable Ar_alm_n -7.4570e-01
	variable Ar_alm_p -1.1240e+00
	variable Ar_mud_n 6.3310e+03
	variable Ar_mud_p 3.3120e+02
	variable Ar_ald_n -2.6870e+00
	variable Ar_ald_p -2.3660e+00
	variable Ar_N0_n 7.3450e+16
	variable Ar_N0_p 5.1360e+17
	variable Ar_alN_n 3.535
	variable Ar_alN_p 3.69
	variable Ar_a_n 0.6273
	variable Ar_a_p 0.8057
	variable Ar_ala_n -1.4410e-01
	variable Ar_ala_p 0.0000e+00
	
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
