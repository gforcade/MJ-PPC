#----------------------------------------------------------------------#
# $Id: Palankovski.tcl,v 1.1 2008/06/27 13:48:24 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Palankovski
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
#! This model is valid for T >= 200 K
#! NOTES: Arora model is used to implement Caughey-Thomas like model from Palankovski.
#! To use this model, activate doping dependent mobility model in sdevice command file.
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! "Analysis and Simulation of Heterostructure Devices"
#! V. Palankovski, R. Quay, Springer-Verlag/Wien, 2004
#! http://www.iue.tuwien.ac.at/phd/palankovski/
#! HISTORY:
#! Created on 2008/06/27 by Sameer Shah

namespace eval Ge::DopingDependence {
    proc init {} {
	variable formula 2

# Parameters from Palankovski
        set muL300_n 3800.0
        set muL300_p 1800.0
        set gamma0_n -1.66
        set gamma0_p -2.33
        set mumin300_n 850.0
        set mumin300_p 300.0
        set gamma1_n 0.0
        set gamma1_p 0.0
        set Cref300_n 2.6e17
        set Cref300_p 1.0e17
        set gamma3_n 0.0
        set gamma3_p 0.0
        set alpha300_n 0.56
        set alpha300_p 1.0
        set gamma4_n 0.0
        set gamma4_p 0.0
        
        set muL_n [expr {$muL300_n*pow($::temp/300.0, $gamma0_n)}]
        set muL_p [expr {$muL300_p*pow($::temp/300.0, $gamma0_p)}]
        if {$::temp < 200} {
            puts stderr "Warning: Ge::DopingDependence::Palankovski model is valid for T >= 200"
        }
        set mumin_n [expr {$mumin300_n*pow($::temp/300.0, $gamma1_n)}]
        set mumin_p [expr {$mumin300_p*pow($::temp/300.0, $gamma1_p)}]
                           
# sdevice parameters (for Arora model) calculated from Palankovski parameters
	variable Ar_mumin_n $mumin300_n
	variable Ar_mumin_p $mumin300_p
	variable Ar_alm_n $gamma1_n
	variable Ar_alm_p $gamma1_p

	variable Ar_mud_n [expr {$muL_n-$mumin_n}]
	variable Ar_mud_p [expr {$muL_p-$mumin_p}]
	variable Ar_ald_n 0.0
	variable Ar_ald_p 0.0

       	variable Ar_N0_n $Cref300_n
	variable Ar_N0_p $Cref300_p
	variable Ar_alN_n $gamma3_n
	variable Ar_alN_p $gamma3_p

	variable Ar_a_n $alpha300_n
	variable Ar_a_p $alpha300_p
	variable Ar_ala_n $gamma4_n
	variable Ar_ala_p $gamma4_p
	
# Mobility calculation using Arora model and sdevice parameters
	set muminA_n [expr {$Ar_mumin_n*pow($::temp/300.0, $Ar_alm_n)}]
	set muminA_p [expr {$Ar_mumin_p*pow($::temp/300.0, $Ar_alm_p)}]
	set mudA_n [expr {$Ar_mud_n*pow($::temp/300.0, $Ar_ald_n)}]
	set mudA_p [expr {$Ar_mud_p*pow($::temp/300.0, $Ar_ald_p)}]
	set N00_n [expr {$Ar_N0_n*pow($::temp/300.0, $Ar_alN_n)}]
	set N00_p [expr {$Ar_N0_p*pow($::temp/300.0, $Ar_alN_p)}]
	set AA_n [expr {$Ar_a_n*pow($::temp/300.0, $Ar_ala_n)}]
	set AA_p [expr {$Ar_a_p*pow($::temp/300.0, $Ar_ala_p)}]

	variable mu_dop_n [expr {$muminA_n + $mudA_n/(1.0 + pow(abs($::doping)/$N00_n,$AA_n))}]
	variable mu_dop_p [expr {$muminA_p + $mudA_p/(1.0 + pow(abs($::doping)/$N00_p,$AA_p))}]
    }
    proc print {} {printPar::DopingDependenceAroraSection}    
}
Ge::DopingDependence::init
