#----------------------------------------------------------------------#
# $Id: Lumb.tcl,v 1.1 2019/07/12 M Beattie $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model from Lumb, 
#! MATERIAL: InAlGaAs_InP
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

namespace eval InAlGaAs_InP::DopingDependence {
    proc init {} {
	variable formula 2

# Parameters from Sotoodeh  #mumax_IGA_p 320.0	
	set mumax_IGA_n 14000.0
	set mumax_IGA_p 320.0
	set mumin_IGA_n 300.0
	set mumin_IGA_p 10.0
	set Nref_IGA_n 1.3e17
	set Nref_IGA_p 4.9e17
	set lambda_IGA_n 0.48
	set lambda_IGA_p 0.403

	set mud_IGA_n [expr {$mumax_IGA_n - $mumin_IGA_n}]
	set mud_IGA_p [expr {$mumax_IGA_p - $mumin_IGA_p}]

	set mu_dop_IGA_n [expr {$mumin_IGA_n + $mud_IGA_n/(1.0 + pow(abs($::doping)/$Nref_IGA_n,$lambda_IGA_n))}]
	set mu_dop_IGA_p [expr {$mumin_IGA_p + $mud_IGA_p/(1.0 + pow(abs($::doping)/$Nref_IGA_p,$lambda_IGA_p))}]

# Parameters from Lumb
	set mumax_IAA_n 1532.0
	set mumax_IAA_p 39.8  
	set mumin_IAA_n 0
	set mumin_IAA_p 0
	set Nref_IAA_n 9.9e17
	set Nref_IAA_p 1.6e18
	set lambda_IAA_n 0.38
	set lambda_IAA_p 0.16

	set mud_IAA_n [expr {$mumax_IAA_n - $mumin_IAA_n}]
	set mud_IAA_p [expr {$mumax_IAA_p - $mumin_IAA_p}]

	set mu_dop_IAA_n [expr {$mumin_IAA_n + $mud_IAA_n/(1.0 + pow(abs($::doping)/$Nref_IAA_n,$lambda_IAA_n))}]
	set mu_dop_IAA_p [expr {$mumin_IAA_p + $mud_IAA_p/(1.0 + pow(abs($::doping)/$Nref_IAA_p,$lambda_IAA_p))}]

# Quaternary calculation

	set mu_dop_n_calc [expr {$mu_dop_IGA_n*(1-$::xMole) + $mu_dop_IAA_n*$::xMole}]
	set mu_dop_p_calc [expr {$mu_dop_IGA_p*(1-$::xMole) + $mu_dop_IAA_p*$::xMole}]

# Alloy scattering

	set mc [expr {0.041*(1-$::xMole)+0.071*$::xMole}]
	set mv [expr {0.45*(1-$::xMole)+0.607*$::xMole}]

	set Delta_Uc 0.53
	set Delta_Uv 1.28

	set mu_al_n [expr {5.0617/(pow($mc,5/2)*$::xMole*(1-$::xMole)*pow($Delta_Uc,2))}]
	set mu_al_p [expr {5.0617/(pow($mv,5/2)*$::xMole*(1-$::xMole)*pow($Delta_Uv,2))}]

	if {$::AS == "on"} {
		set mu_n [expr {1/(1/$mu_dop_n_calc + 1/$mu_al_n)}]
		set mu_p [expr {1/(1/$mu_dop_p_calc + 1/$mu_al_p)}]
	} elseif {$::AS == "off"} {
		set mu_n $mu_dop_n_calc
		set mu_p $mu_dop_p_calc
	}

# sdevice parameters (for Arora model) - calculated mobility is mumin, all else go to zero
	variable Ar_mumin_n $mu_n
	variable Ar_mumin_p $mu_p
	variable Ar_alm_n 0.0
	variable Ar_alm_p 0.0

	variable Ar_mud_n 0
	variable Ar_mud_p 0
	variable Ar_ald_n 0.0
	variable Ar_ald_p 0.0

       	variable Ar_N0_n 1
	variable Ar_N0_p 1
	variable Ar_alN_n 0
	variable Ar_alN_p 0

	variable Ar_a_n 0
	variable Ar_a_p 0
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
InAlGaAs_InP::DopingDependence::init
