#----------------------------------------------------------------------#
# $Id: Sotoodeh.tcl,v 1.2 2007/12/06 14:29:30 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Sotoodeh
#! MATERIAL: AlGaAs
#! PROPERTY: Constant Mobility
#! EXPRESSION: 
#! Temperature dependent mobility is calculated using
#! mu_const = mumax (T/T0)^(-Exponent) 
#! CALCULATED PARAMETER: 
#! mu_const_n and mu_const_p returns temperature dependent mobility for n and p type carriers respectively.
#! VALIDITY: 
#! NOTES: This model is temperature dependent and doping concentration independent. 
#! The mobility value is the low doping mobility value from the doping dependent Sotoodeh model
#! SDEVICE: Mobility(ConstantMobility)
#! REFERENCE: 
#! 1) M.Sotoodeh, A.H.Khalid, and A.A.Rezazadeh, "Empirical low-field mobility model for III-V compounds applicable in device simulation codes,
#! " Journal of Applied Physics, vol. 87, no. 6, pp.2890-2900, 2000
#! 2) J.E.Sutherland and J.R.Hauser, "A Computer Analysis of Heterojunction and Graded Composition Solar Cells,
#! IEEE Trans. on Electron Devices, vol. ED-24, no. 4, pp.363-372, 1977
#! HISTORY:
#! Created on 2007/12/06 by Sameer Shah

namespace eval AlGaAs::ConstantMobility {
    proc init {} {
	variable formula 1
# Define parameters from Sotoodeh
    # GaAs Parameters from Sotoodeh	
	set mumax_n_GaAs 9400.0
	set mumax_p_GaAs 491.5
	set theta1_n_GaAs 2.1
	set theta1_p_GaAs 2.2
	
	set Eg_Gamma_GaAs 1.422
        set Eg_X_GaAs 1.899
	set mn_Gamma_GaAs 0.065
        set mn_X_GaAs 0.85
	set eps_s_GaAs 12.90
	set eps_inf_GaAs 10.92
	
    # AlAs Parameters from Sotoodeh
	set mumax_n_AlAs 400.0
	set mumax_p_AlAs 200.0
	set theta1_n_AlAs 2.1
	set theta1_p_AlAs 2.24
	
	set Eg_Gamma_AlAs 2.799
        set Eg_X_AlAs 2.163
	set mn_Gamma_AlAs 0.150
        set mn_X_AlAs 0.71
	set eps_s_AlAs 10.06
	set eps_inf_AlAs 8.16
        
    # AlGaAs Parameters for x=0.3 from Sotoodeh
        set x0 0.3
        set mumax_p_x0 240.0
        
    # Bowing parameters for bandgap of AlGaAs
        set b_Gamma 0
        set b_X 0.143
        
# Calculation of  parameters for electrons
    # Calculate mumax_n, for AlGaAs, assuming that all electrons are in gamma and X valley               
	# Interpolation procedure for eps
	proc compute_eps {xMole eps_AlAs eps_GaAs} {
	    set eps_factor_AlAs [expr {($eps_AlAs-1.0)/($eps_AlAs+2.0)}]
	    set eps_factor_GaAs [expr {($eps_GaAs-1.0)/($eps_GaAs+2.0)}]
	    set eps_num [expr {1 + 2*$xMole*$eps_factor_AlAs + 2*(1-$xMole)*$eps_factor_GaAs}]
	    set eps_den [expr {1 - $xMole*$eps_factor_AlAs - (1-$xMole)*$eps_factor_GaAs}]
	    set eps [expr {$eps_num/$eps_den}]
	}	    
        # Calculate mumax_n_D, mumax_n_I
	set mn_Gamma [expr {[compute_ternary $::xMole $mn_Gamma_AlAs $mn_Gamma_GaAs]}]	    
        set eps_s [expr {[compute_eps $::xMole $eps_s_AlAs $eps_s_GaAs]}]
	set eps_inf [expr {[compute_eps $::xMole $eps_inf_AlAs $eps_inf_GaAs]}]
        set inv_eps_s [expr {1.0/$eps_s}]
        set inv_eps_inf [expr {1.0/$eps_inf}]
        set inv_eps_s_GaAs [expr {1.0/$eps_s_GaAs}]
        set inv_eps_inf_GaAs [expr {1.0/$eps_inf_GaAs}]
        set eps_term [expr {($inv_eps_inf_GaAs - $inv_eps_s_GaAs)/($inv_eps_inf - $inv_eps_s)}]
        
        set mumax_n_D [expr {$mumax_n_GaAs*$eps_term*pow(($mn_Gamma_GaAs/$mn_Gamma), 3.0/2.0)}]	           
        set mumax_n_I $mumax_n_AlAs
	    
        # Calculate R_Gamma, the fraction of electrons in the Gamma valley
        set mn_X [expr {[compute_ternary $::xMole $mn_X_AlAs $mn_X_GaAs]}]
        set Eg_Gamma [expr {[compute_ternary $::xMole $Eg_Gamma_AlAs $Eg_Gamma_GaAs $b_Gamma]}]
        set Eg_X [expr {[compute_ternary $::xMole $Eg_X_AlAs $Eg_X_GaAs $b_X]}]
        set R_Gamma_inv [expr {1+ exp(($Eg_Gamma-$Eg_X)/($::kB*$::temp/$::q))*pow(($mn_X/$mn_Gamma),3.0/2.0)}]
        set R_Gamma [expr {1.0/$R_Gamma_inv}]
	           
        variable mumax_n [expr {$mumax_n_D*$R_Gamma + $mumax_n_I*(1-$R_Gamma)}]
        
    # Calculate theta1_n
	set theta1_n [expr {((1-$::xMole)*($theta1_n_GaAs)+($::xMole)*($theta1_n_AlAs))/(1+($::xMole)*(1-$::xMole))}]

# Calculation of parameters for holes
    # Calculation of  mumax_p, mumin_p lambda_p, Nref_p
        
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
        set K_mumax_p [expr {[compute_bowPar $x0 $mumax_p_x0 $mumax_p_AlAs $mumax_p_GaAs]}]
        
        # Calculate mumax_p, theta1_p
        variable mumax_p [expr {[::compute_ternary $::xMole $mumax_p_AlAs $mumax_p_GaAs $K_mumax_p]}]        
	set theta1_p [expr {((1-$::xMole)*($theta1_p_GaAs)+($::xMole)*($theta1_p_AlAs))/(1+($::xMole)*(1-$::xMole))}]

# Constant mobility calculation using Constant mobility model and sdevice parameters
	variable Exponent_n $theta1_n
	variable Exponent_p $theta1_p
	variable mutunnel_n 0.05 ;# default parameter from sdevice
	variable mutunnel_p 0.05 ;# default parameter from sdevice

	variable mu_const_n 
	variable mu_const_p
	
	set mu_const_n [expr {$mumax_n*pow($::temp/300.0, -$Exponent_n)}]
	set mu_const_p [expr {$mumax_p*pow($::temp/300.0, -$Exponent_p)}]  	
   }
    proc print {} {printPar::ConstantMobilitySection}    
}
AlGaAs::ConstantMobility::init
