#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.5 2008/03/28 06:04:07 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors in [eV]
#! deltaEg_p return BGN for acceptors in [eV]
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
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

namespace eval GaAs::TableBGN {
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
        
# Parameters from Jain-Roulston
        set A_n 16.3   
        set B_n 7.47
        set C_n 90.65	        
        set A_p 9.71
        set B_p 12.19
        set C_p 3.88

# Calculate deltaEg using Jain Roulston model
        set deltaEg_n [list]
        foreach doping $Nd {
     	    set deltaEg [expr {($A_n*pow($doping/1.0e18,1.0/3.0) + $B_n*pow($doping/1.0e18,1.0/4.0) + $C_n*pow($doping/1.0e18,1.0/2.0))*1e-3}]
            lappend deltaEg_n $deltaEg
	    }

        set deltaEg_p [list]
        foreach doping $Na {
     	    set deltaEg [expr {($A_p*pow($doping/1.0e18,1.0/3.0) + $B_p*pow($doping/1.0e18,1.0/4.0) + $C_p*pow($doping/1.0e18,1.0/2.0))*1e-3}]            
            lappend deltaEg_p $deltaEg
	    }    
    }
    proc print {} {printPar::TableBGNSection}
}
GaAs::TableBGN::init
