#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/07/15 05:58:02 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: AlGaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i, deltaEg [eV]
#! VALIDITY: 
#! This model is valid for both n-AlAs and p-AlAs
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2008/07/15 by Sameer Shah

namespace eval AlGaAs::JainRoulston {
    proc init {} {		
# Parameters from Levinshtein
        set A_n_GaAs [expr 16.3*pow(1e-18,1./3)*1e-3]
        set A_p_GaAs [expr 9.71*pow(1e-18,1./3)*1e-3]
        set B_n_GaAs [expr 7.47*pow(1e-18,1./4)*1e-3] 
        set B_p_GaAs [expr 12.19*pow(1e-18,1./4)*1e-3]
        set C_n_GaAs [expr 90.65*pow(1e-18,1./2)*1e-3] 	           
        set C_p_GaAs [expr 3.88*pow(1e-18,1./2)*1e-3] 

        set A_n_AlAs 9.76e-9
        set A_p_AlAs 10.6e-9
        set B_n_AlAs 4.33e-7
        set B_p_AlAs 5.47e-7
        set C_n_AlAs 2.93e-12	        
        set C_p_AlAs 3.01e-12

# sdevice parameters (for JainRoulston model) calculated using parameters from Levinshtein
# Linear interpolation is assumed
        variable A_n [expr {[::compute_ternary $::xMole $A_n_AlAs $A_n_GaAs]}]
        variable B_n [expr {[::compute_ternary $::xMole $B_n_AlAs $B_n_GaAs]}]
        variable C_n [expr {[::compute_ternary $::xMole $C_n_AlAs $C_n_GaAs]}]
        variable A_p [expr {[::compute_ternary $::xMole $A_p_AlAs $A_p_GaAs]}]
        variable B_p [expr {[::compute_ternary $::xMole $B_p_AlAs $B_p_GaAs]}]
        variable C_p [expr {[::compute_ternary $::xMole $C_p_AlAs $C_p_GaAs]}]
        variable D_n 0.0
        variable D_p 0.0

# Calculation of bandgap narrowing   
        if { $::doping > 0.0 } {
	    variable deltaEg [expr {$A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)}]
    	} elseif { $::doping < 0.0 } {
	    variable deltaEg [expr {$A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)}]
	}   
    }
    proc print {} {printPar::JainRoulstonSection}
}
AlGaAs::JainRoulston::init
