#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/07/15 06:57:10 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: GaInP
#! PROPERTY: Bandgap narrowing (BGN)
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i, deltaEg [eV]
#! VALIDITY: 
#! This model is valid for both n-GaP and p-GaP
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2008/07/15 by Sameer Shah

namespace eval GaInP::JainRoulston {
    proc init {} {		
# Parameters from Levinshtein
        set A_n_InP 17.2e-9
        set A_p_InP 10.3e-9
        set B_n_InP 2.62e-7 
        set B_p_InP 4.43e-7
        set C_n_InP 98.4e-12 	           
        set C_p_InP 3.38e-12 

        set A_n_GaP 10.7e-9 
        set A_p_GaP 12.7e-9
        set B_n_GaP 3.45e-7
        set B_p_GaP 5.85e-7
        set C_n_GaP 9.97e-12	        
        set C_p_GaP 3.90e-12

# sdevice parameters (for JainRoulston model) calculated using parameters from Levinshtein
# Linear interpolation is assumed
        variable A_n [expr {[::compute_ternary $::xMole $A_n_GaP $A_n_InP]}]
        variable B_n [expr {[::compute_ternary $::xMole $B_n_GaP $B_n_InP]}]
        variable C_n [expr {[::compute_ternary $::xMole $C_n_GaP $C_n_InP]}]
        variable A_p [expr {[::compute_ternary $::xMole $A_p_GaP $A_p_InP]}]
        variable B_p [expr {[::compute_ternary $::xMole $B_p_GaP $B_p_InP]}]
        variable C_p [expr {[::compute_ternary $::xMole $C_p_GaP $C_p_InP]}]
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
GaInP::JainRoulston::init
