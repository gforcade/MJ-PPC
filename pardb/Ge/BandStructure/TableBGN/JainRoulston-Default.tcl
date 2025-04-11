#----------------------------------------------------------------------#
# $Id: JainRoulston-Default.tcl,v 1.4 2008/03/28 13:54:24 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: Ge
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors [eV]
#! deltaEg_p return BGN for acceptors [eV]
#! VALIDITY: 
#! This model is valid for both n-Ge and p-Ge
#! NOTES:
#! The Default JainRoulston model is implemented here in the form of TableBGN model. 
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! Sentaurus Device User Guide 
#! Created on 2007/08/29 by Sameer Shah

namespace eval Ge::TableBGN {
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
        
# Parameters from sdevice        
	variable A_n 7.3000e-09	;# [eV cm]
	variable A_p 8.2100e-09	;# [eV cm]
	variable B_n 2.5700e-07	;# [eV cm^(3/4)]
	variable B_p 2.9100e-07	;# [eV cm^(3/4)]
	variable C_n 2.2900e-12	;# [eV cm^(3/2)]
	variable C_p 3.5800e-12	;# [eV cm^(3/2)]
	variable D_n 2.0300e-12	;# [eV cm^(3/2)]
	variable D_p 2.1900e-12	;# [eV cm^(3/2)]

# Calculate deltaEg using Jain Roulston model from sdevice
        set deltaEg_n [list]
        foreach doping $Nd {
     	    set deltaEg [expr {$A_n*pow($doping,1.0/3.0) + $B_n*pow($doping,1.0/4.0) + $C_n*pow($doping,1.0/2.0) + $D_n*pow($doping,1.0/2.0)}]
            lappend deltaEg_n $deltaEg
	    }

        set deltaEg_p [list]
        foreach doping $Na {
    	    set deltaEg [expr {$A_p*pow($doping,1.0/3.0) + $B_p*pow($doping,1.0/4.0) + $C_p*pow($doping,1.0/2.0) + $D_p*pow($doping,1.0/2.0)}]
            lappend deltaEg_p $deltaEg
	    }    
    }
    proc print {} {printPar::TableBGNSection}
}
Ge::TableBGN::init

