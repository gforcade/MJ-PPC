#----------------------------------------------------------------------#
# $Id:$
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Sotoodeh
#! MATERIAL: GaInP
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
#! Created on 2008/06/30 by Sameer Shah

namespace eval GaInP::DopingDependence {
    proc init {} {
	variable formula 2
# Parameters from Sotoodeh
    # InP Parameters from Sotoodeh	
	set mumax_n_InP 5200.0
	set mumax_p_InP 170.0
	set mumin_n_InP 400.0
	set mumin_p_InP 10.0
	set Nref_n_InP 3.0e17
	set Nref_p_InP 4.87e17
	set lambda_n_InP 0.47
	set lambda_p_InP 0.62
	set theta1_n_InP 2.0
	set theta1_p_InP 2.0
	set theta2_n_InP 3.25
	set theta2_p_InP 3.0
	
	set Eg_Gamma_InP 1.351
        set Eg_X_InP 2.2
	set mn_Gamma_InP 0.079
        set mn_X_InP 0.676
	set eps_s_InP 12.61
	set eps_inf_InP 9.61
	
    # GaP Parameters from Sotoodeh
	set mumax_n_GaP 152.0
	set mumax_p_GaP 147.0
	set mumin_n_GaP 10.0
	set mumin_p_GaP 10.0
	set Nref_n_GaP 4.4e18
	set Nref_p_GaP 1.0e18
	set lambda_n_GaP 0.80
	set lambda_p_GaP 0.85
	set theta1_n_GaP 1.60
	set theta1_p_GaP 1.98
	set theta2_n_GaP 0.71
	set theta2_p_GaP 0.0
	
	set Eg_Gamma_GaP 2.760
        set Eg_X_GaP 2.261        
	set mn_Gamma_GaP 0.126
        set mn_X_GaP 0.82
	set eps_s_GaP 11.10
	set eps_inf_GaP 9.08
        
    # Ga(x)In(1-x)P Parameters for x=0.51 from Sotoodeh
        set x0 0.51
        set mumax_n_x0 4300
        set mumin_n_x0 400
        set Nref_n_x0 2.0e16
        set Nref_p_x0 1.5e17
        set lambda_n_x0 0.70
        set lambda_p_x0 0.80
        set theta1_n_x0 1.66
        set theta1_p_x0 2.0       
        
    # Bowing parameters for bandgap of GaInP
        set b_Gamma 0.67
        set b_X 0.17
        
# Calculation of Sotoodeh parameters of GaInP from Sotoodeh parameters of GaP and InP
        
    # Calculate mumin_n and mumax_n, for GaInP, assuming that all electrons are in gamma and X valley
        set mumax_n_D [expr {(1-$::xMole/0.51)*$mumax_n_InP + ($::xMole/0.51)*$mumax_n_x0}]
        set mumin_n_D [expr {(1-$::xMole/0.51)*$mumin_n_InP + ($::xMole/0.51)*$mumin_n_x0}]
            
	# Interpolation procedure for eps
	proc compute_eps {xMole eps_GaP eps_InP} {
	    set eps_factor_GaP [expr {($eps_GaP-1.0)/($eps_GaP+2.0)}]
	    set eps_factor_InP [expr {($eps_InP-1.0)/($eps_InP+2.0)}]
	    set eps_num [expr {1 + 2*$xMole*$eps_factor_GaP + 2*(1-$xMole)*$eps_factor_InP}]
	    set eps_den [expr {1 - $xMole*$eps_factor_GaP - (1-$xMole)*$eps_factor_InP}]
	    set eps [expr {$eps_num/$eps_den}]
	}	    
        
	set mn_Gamma [expr {[compute_ternary $::xMole $mn_Gamma_GaP $mn_Gamma_InP]}]
        
        set eps_s [expr {[compute_eps $::xMole $eps_s_GaP $eps_s_InP]}]
	set eps_inf [expr {[compute_eps $::xMole $eps_inf_GaP $eps_inf_InP]}]
        set inv_eps_s [expr {1.0/$eps_s}]
        set inv_eps_inf [expr {1.0/$eps_inf}]
        set inv_eps_s_InP [expr {1.0/$eps_s_InP}]
        set inv_eps_inf_InP [expr {1.0/$eps_inf_InP}]
        set eps_term [expr {($inv_eps_inf_InP - $inv_eps_s_InP)/($inv_eps_inf - $inv_eps_s)}]
        
        set mn_indir_GaP $mn_X_GaP
        set mumin_n_I [expr {$mumin_n_InP*$eps_term*pow(($mn_indir_GaP/$mn_indir), 3.0/2.0)}]
   
        set mumax_n_I [expr {$mumax_n_InP*$eps_term*pow(($mn_indir_GaP/$mn_indir), 3.0/2.0)}]
	    
        set mumin_n_I $mumin_n_GaP
        set mumax_n_I $mumax_n_GaP
	    
        # Calculate R_Gamma, the fraction of electrons in the Gamma valey
        set mn_X [expr {[compute_ternary $::xMole $mn_X_GaP $mn_X_InP]}]
        set Eg_Gamma [expr {[compute_ternary $::xMole $Eg_Gamma_GaP $Eg_Gamma_InP $b_Gamma]}]
        set Eg_X [expr {[compute_ternary $::xMole $Eg_X_GaP $Eg_X_InP $b_X]}]
        set R_Gamma_inv [expr {1+ exp(($Eg_Gamma-$Eg_X)/($::kB*$::temp/$::q))*pow(($mn_X/$mn_Gamma),3.0/2.0)}]
        set R_Gamma [expr {1.0/$R_Gamma_inv}]
	    
        set mumin_n [expr {$mumin_n_D*$R_Gamma + $mumin_n_I*(1-$R_Gamma)}]
        set mumax_n [expr {$mumax_n_D*$R_Gamma + $mumax_n_I*(1-$R_Gamma)}]
        
    # Calculate lambda_n, Nref_n, theta2_n and theta1_n
	set lambda_n [expr {[::compute_ternary $::xMole $lambda_n_GaP $lambda_n_InP]}]
	set Nref_n [expr {(pow($Nref_n_InP, [expr {1-$::xMole}]))*(pow($Nref_n_GaP, $::xMole))}]
	set theta2_n [expr {[::compute_ternary $::xMole $theta2_n_GaP $theta2_n_InP]}]
	set theta1_n [expr {((1-$::xMole)*($theta1_n_InP)+($::xMole)*($theta1_n_GaP))/(1+($::xMole)*(1-$::xMole))}]

    # Calculation of mumax_p, mumin_p, Nref, lambda, theta1 using quadratic interpolation between
    # the corresponding values for InP, In(0.49)Ga(0.51)P
        
        # Define procedure for calculating bowing parameters
        proc compute_bowPar {x Px AB BC} {
            #   This procedure returns the bowing parameter
            #   by a quadratic interpolation between the binary compounds AB and BA and 
            #   the parameter value, Px of the ternary at known x
            #
            #   P(A(x)B(1-x)C) = AB*x+BC*(1-x)-K*x*(1-x)
            # 
            # Arguments:
            #   x -        mole fraction of compound AxB(1-x)C
            #   AB -       AB binary compound parameter value
            #   BC -       BC binary compound parameter value
            #   Px -       Parameter value of ternary for x
            #   K -        bowing parameter (note the minus sign here)
            if {$x != 0 && $x != 1} {
                set K [expr {($x*$AB + (1-$x)*$BC-$Px)/($x*(1-$x))}]
            } else {
                exit -1
                puts stderr "Error: x = 0 or x = 1! Specify a different value of x between (0,1)!"
            }
        }
        # Calculate bowing parameters
        set K_mumax_p [expr {[compute_bowPar $x0 $mumax_p_x0 $mumax_p_GaP $mumax_p_InP]}]
        set K_mumin_p [expr {[compute_bowPar $x0 $mumin_p_x0 $mumin_p_GaP $mumin_p_InP]}]
        set K_lambda_n [expr {[compute_bowPar $x0 $lambda_n_x0 $lambda_n_GaP $lambda_n_InP]}]           
        set K_lambda_p [expr {[compute_bowPar $x0 $lambda_p_x0 $lambda_p_GaP $lambda_p_InP]}]
        set K_theta1_n [expr {[compute_bowPar $x0 $theta1_n_x0 $theta1_n_GaP $theta1_n_InP]}]           
        set K_theta1_p [expr {[compute_bowPar $x0 $theta1_p_x0 $theta1_p_GaP $theta1_p_InP]}]
        
        set logNref_n_x0 [expr {log10($Nref_n_x0)}]
        set logNref_n_GaP [expr {log10($Nref_n_GaP)}]
        set logNref_n_InP [expr {log10($Nref_n_InP)}]
        set K_logNref_n [expr {[compute_bowPar $x0 $logNref_n_x0 $logNref_n_GaP $logNref_n_InP]}]
        
        set logNref_p_x0 [expr {log10($Nref_p_x0)}]
        set logNref_p_GaP [expr {log10($Nref_p_GaP)}]
        set logNref_p_InP [expr {log10($Nref_p_InP)}]
        set K_logNref_p [expr {[compute_bowPar $x0 $logNref_p_x0 $logNref_p_GaP $logNref_p_InP]}]
        
        # Calculation of mumax_p, mumin_p, Nref, lambda, theta1 for a particular xMole
        set mumax_p [expr {[::compute_ternary $::xMole $mumax_p_GaP $mumax_p_InP $K_mumax_p]}]
        set mumin_p [expr {[::compute_ternary $::xMole $mumin_p_GaP $mumin_p_InP $K_mumin_p]}]
        set lambda_n [expr {[::compute_ternary $::xMole $lambda_n_GaP $lambda_n_InP $K_lambda_n]}]        
        set lambda_p [expr {[::compute_ternary $::xMole $lambda_p_GaP $lambda_p_InP $K_lambda_p]}]
        set theta1_n [expr {[::compute_ternary $::xMole $theta1_n_GaP $theta1_n_InP $K_theta1_n]}]        
        set theta1_p [expr {[::compute_ternary $::xMole $theta1_p_GaP $theta1_p_InP $K_theta1_p]}]


        set logNref_n [expr {[::compute_ternary $::xMole $logNref_n_GaP $logNref_n_InP $K_logNref_n]}]
        set Nref_n [expr {pow(10,$logNref_n)}]        
        set logNref_p [expr {[::compute_ternary $::xMole $logNref_p_GaP $logNref_p_InP $K_logNref_p]}]
        set Nref_p [expr {pow(10,$logNref_p)}]
        
    # Calculation of theta2 using linear interpolation for a particular xMole
	set theta2_n [expr {[::compute_ternary $::xMole $theta2_n_GaP $theta2_n_InP]}]
        set theta2_p [expr {[::compute_ternary $::xMole $theta2_p_GaP $theta2_p_InP]}]
        
# sdevice parameters (for Arora model) calculated from Sotoodeh parameters
	variable mumin1_n $mumin_n
	variable mumin1_p $mumin_p
	variable mumin2_n $mumin_n
	variable mumin2_p $mumin_p
	variable mu1_n 0.0
	variable mu1_p 0.0
	variable Pc_n 0.0
	variable Pc_p 0.0
	variable Cr_n [expr {$Nref_n*pow($::temp/300.0, $theta2_n)}]
	variable Cr_p [expr {$Nref_p*pow($::temp/300.0, $theta2_p)}]
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
GaInP::DopingDependence::init
