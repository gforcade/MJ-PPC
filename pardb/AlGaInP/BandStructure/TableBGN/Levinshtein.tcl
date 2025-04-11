#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/08/04 10:11:58 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: GaInP
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors in [eV]
#! deltaEg_p return BGN for acceptors in [eV]
#! VALIDITY: 
#! This model is valid for both n-GaInP and p-GaInP
#! NOTES: 
#! The JainRoulston model from Levinshtein is implemented here in the form of TableBGN model.
#! Also, this model uses three parameters, A, B and C, 
#! whereas the sdevice implementation uses four parameters, A, B, C and D
#! Use this model for regions with non-uniform doping profiles
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 200808/04 by Sameer Shah

namespace eval GaInP::TableBGN {
    proc init {} {
	variable Na
	variable Nd
	variable deltaEg_n
	variable deltaEg_p

# Create lists of doping concentration 
    # Method I:   
        if 0 {
        set N 60
        set min 1.0e15
        set max 1.0e20
        set Nd [logspace $min $max $N]
        set Na [logspace $min $max $N]
        }   
    # Method II: Create Na={1,2,3,...,9,10,20,30,...,90,100,200,300,...,900,1000}     
       set N 10
       # N = number of linearly spaced elements in a decade interval
       set min 1e15
       set max 1e20
       set Nd [decadelinspace $min $max $N]
       set Na $Nd
        
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
        
# sdevice parameters calculated using parameters from Levinshtein
# Linear interpolation is assumed
        set A_n [expr {[::compute_ternary $::xMole $A_n_GaP $A_n_InP]}]
        set B_n [expr {[::compute_ternary $::xMole $B_n_GaP $B_n_InP]}]
        set C_n [expr {[::compute_ternary $::xMole $C_n_GaP $C_n_InP]}]
        set A_p [expr {[::compute_ternary $::xMole $A_p_GaP $A_p_InP]}]
        set B_p [expr {[::compute_ternary $::xMole $B_p_GaP $B_p_InP]}]
        set C_p [expr {[::compute_ternary $::xMole $C_p_GaP $C_p_InP]}]

# Calculation of bandgap narrowing
        set deltaEg_n [list]
        foreach doping $Nd {
     	    set deltaEg [expr {$A_n*pow($doping,1.0/3.0) + $B_n*pow($doping,1.0/4.0) + $C_n*pow($doping,1.0/2.0)}]
            lappend deltaEg_n $deltaEg
	}

        set deltaEg_p [list]
        foreach doping $Na {
     	    set deltaEg [expr {$A_p*pow($doping,1.0/3.0) + $B_p*pow($doping,1.0/4.0) + $C_p*pow($doping,1.0/2.0)}]            
            lappend deltaEg_p $deltaEg
	}    
    }
    proc print {} {printPar::TableBGNSection}
}
GaInP::TableBGN::init
