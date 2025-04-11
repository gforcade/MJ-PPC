#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.3 2008/07/15 05:54:26 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: AlGaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors in [eV]
#! deltaEg_p return BGN for acceptors in [eV]
#! VALIDITY: 
#! This model is valid for both n-AlGaAs and p-AlGaAs
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
#! Created on 2007/08/29 by Sameer Shah

namespace eval AlGaAs::TableBGN {
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
        set A_n_GaAs 16.3  
        set B_n_GaAs 2.3622
        set C_n_GaAs 90.65	        
        set A_p_GaAs 9.71
        set B_p_GaAs 3.8548
        set C_p_GaAs 3.88

        set A_n_AlAs 9.76
        set B_n_AlAs 4.33
        set C_n_AlAs 2.93	        
        set A_p_AlAs 10.6
        set B_p_AlAs 5.47
        set C_p_AlAs 3.01
        
# sdevice parameters calculated using parameters from Levinshtein
# Linear interpolation is assumed
        set A_n [expr {[::compute_ternary $::xMole $A_n_AlAs $A_n_GaAs]}]
        set B_n [expr {[::compute_ternary $::xMole $B_n_AlAs $B_n_GaAs]}]
        set C_n [expr {[::compute_ternary $::xMole $C_n_AlAs $C_n_GaAs]}]
        set A_p [expr {[::compute_ternary $::xMole $A_p_AlAs $A_p_GaAs]}]
        set B_p [expr {[::compute_ternary $::xMole $B_p_AlAs $B_p_GaAs]}]
        set C_p [expr {[::compute_ternary $::xMole $C_p_AlAs $C_p_GaAs]}]

# Calculation of bandgap narrowing
        set deltaEg_n [list]
        foreach doping $Nd {
     	    set deltaEg [expr {1e-9*$A_n*pow($doping,1.0/3.0) + 1e-7*$B_n*pow($doping,1.0/4.0) + 1e-12*$C_n*pow($doping,1.0/2.0)}]
            lappend deltaEg_n $deltaEg
	}

        set deltaEg_p [list]
        foreach doping $Na {
     	    set deltaEg [expr {1e-9*$A_p*pow($doping,1.0/3.0) + 1e-7*$B_p*pow($doping,1.0/4.0) + 1e-12*$C_p*pow($doping,1.0/2.0)}]            
            lappend deltaEg_p $deltaEg
	}    
    }
    proc print {} {printPar::TableBGNSection}
}
AlGaAs::TableBGN::init
