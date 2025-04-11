#----------------------------------------------------------------------#
# $Id: Sotoodeh.tcl,v 1.1 2021/11/17 21:28:12 G Forcade Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Sotoodeh,   xMole is ____InP____ molefraction
#! MATERIAL: GaInPAs
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
#! This model is valid for GaInPAs 
#! NOTES: Arora model is used to implement Caughey-Thomas like model from Sotoodeh.
#! To use this model, activate doping dependent mobility model in sdevice command file.
#! SDEVICE: Mobility(DopingDependence)
#! REFERENCE: 
#! M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,
#! " Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! HISTORY:
#! Created on 2021/11/17 by Gavin Forcade - SUNLAB uOttawa

namespace eval GaInPAs_InP::DopingDependence {
    proc init {} {
	variable formula 2

#Lattice matching condition for Ga(y)In(1-y)P(x)As(1-x) to InP. From Adachi 2017.   
	set xMol $::xMole
	set yMol [expr {(0.1893 - 0.1893*$xMol)/(0.4050 + 0.0132*$xMol)}] 

#mu [cm-2 V-1 s]
#Nref [cm-3]

#In(1-y)Ga(y)As mobility parameters from Sotoodeh
	set mumax_n_InGaAs [expr {34000.0 - 58470.0*$yMol + 33870.0*$yMol*$yMol}]
	set mumax_p_InGaAs [expr {530.0 - 808.9*$yMol + 770.4*$yMol*$yMol}]
	set mumin_n_InGaAs [expr {1000.0 - 2367.0*$yMol + 1867.0*$yMol*$yMol}]
	set mumin_p_InGaAs [expr {20.0 - 40.14*$yMol + 40.14*$yMol*$yMol}]
	set Log_Nref_n_InGaAs [expr {18.0414 - 2.602762*$yMol + 1.339512*$yMol*$yMol}]
	set Log_Nref_p_InGaAs [expr {17.0414 + 2.490303*$yMol - 2.361441*$yMol*$yMol}]
	set lambda_n_InGaAs [expr {0.3200 + 0.5767*$yMol - 0.5027*$yMol*$yMol}]
	set lambda_p_InGaAs [expr {0.4600 - 0.1579*$yMol + 0.07788*$yMol*$yMol}]
	set theta1_n_InGaAs [expr {1.570 - 0.3897*$yMol + 0.9197*$yMol*$yMol}]
	set theta1_p_InGaAs [expr {2.300 - 2.762*$yMol + 2.662*$yMol*$yMol}]
	set theta2_n_InGaAs [expr {3.000 + 2.730*$yMol - 2.730*$yMol*$yMol}]
	set theta2_p_InGaAs 3.0


#In(1-y)Ga(y)P mobility parameters from Sotoodeh (umax_n_InGaP only goes up to y~0.47 so not interpolating into the X/L valleys)
	set mumax_n_InGaP [expr {5200.0*(1.0 - $yMol/0.51) + 4300.0*$yMol/0.51 }]
	set mumax_p_InGaP [expr {170.0 - 56.09*$yMol + 33.09*$yMol*$yMol}]
	set mumin_n_InGaP 400.0
	set mumin_p_InGaP [expr {10.0 + 20.01*$yMol - 20.01*$yMol*$yMol}]
	set Log_Nref_n_InGaP [expr {17.47712 - 5.920181*$yMol + 7.086514*$yMol*$yMol}]
	set Log_Nref_p_InGaP [expr {17.68753 - 2.3718*$yMol + 2.684271*$yMol*$yMol}]
	set lambda_n_InGaP [expr {0.4700 + 0.5769*$yMol - 0.2469*$yMol*$yMol}]
	set lambda_p_InGaP [expr {0.6200 + 0.4809*$yMol - 0.2509*$yMol*$yMol}]
	set theta1_n_InGaP [expr {2.0 - 0.9442177*$yMol + 0.5442177*$yMol*$yMol}]
	set theta1_p_InGaP [expr {2.00 + 0.0208*$yMol - 0.0408*$yMol*$yMol}]
	set theta2_n_InGaP [expr {3.25*(1.0 - $yMol) + 0.71*$yMol}]
	set theta2_p_InGaP [expr {3.0*(1.0 - $yMol) + 0.0*$yMol}]





# (GaInAs)InPx Parameters in Sotoodeh format	
	set mumax_n [expr {($mumax_n_InGaP*$xMol + $mumax_n_InGaAs*(1.0 - $xMol))/(1.0 + 6.0*$xMol*(1.0 - $xMol))}]
	set mumax_p [expr {($mumax_p_InGaP*$xMol + $mumax_p_InGaAs*(1.0 - $xMol))/(1.0 + 6.0*$xMol*(1.0 - $xMol))}]
	set mumin_n [expr {($mumin_n_InGaP*$xMol + $mumin_n_InGaAs*(1.0 - $xMol))/(1.0 + 6.0*$xMol*(1.0 - $xMol))}]
	set mumin_p [expr {$mumin_p_InGaP*$xMol + $mumin_p_InGaAs*(1.0 - $xMol)}]
	set Log_Nref_n [expr {$Log_Nref_n_InGaP*$xMol + $Log_Nref_n_InGaAs*(1.0 - $xMol)}]
	set Nref_n [expr {pow(10.0,$Log_Nref_n)}]
	set Log_Nref_p [expr {$Log_Nref_p_InGaP*$xMol + $Log_Nref_p_InGaAs*(1.0 - $xMol)}]
	set Nref_p [expr {pow(10.0,$Log_Nref_p)}]
	set lambda_n [expr {$lambda_n_InGaP*$xMol + $lambda_n_InGaAs*(1.0 - $xMol)}]
	set lambda_p [expr {$lambda_p_InGaP*$xMol + $lambda_p_InGaAs*(1.0 - $xMol)}]
	set theta1_n [expr {($theta1_n_InGaP*$xMol + $theta1_n_InGaAs*(1.0 - $xMol))/(1.0 + 1.0*$xMol*(1.0 - $xMol))}]
	set theta1_p [expr {($theta1_p_InGaP*$xMol + $theta1_p_InGaAs*(1.0 - $xMol))/(1.0 + 1.0*$xMol*(1.0 - $xMol))}]
	set theta2_n [expr {$theta2_n_InGaP*$xMol + $theta2_n_InGaAs*(1.0 - $xMol)}]
	set theta2_p [expr {$theta2_p_InGaP*$xMol + $theta2_p_InGaAs*(1.0 - $xMol)}]



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
GaInPAs_InP::DopingDependence::init
