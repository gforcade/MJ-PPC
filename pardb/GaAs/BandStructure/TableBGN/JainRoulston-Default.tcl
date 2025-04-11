#----------------------------------------------------------------------#
# $Id: JainRoulston-Default.tcl,v 1.5 2008/03/28 06:00:41 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Jain Roulston Table based model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors [eV]
#! deltaEg_p return BGN for acceptors [eV]
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! NOTES: 
#! The Default JainRoulston model is implemented here in the form of TableBGN model. 
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY
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
        
# Parameters from sdevice
        set A_n 1.6500e-08	;# [eV cm]
	    set A_p 9.7700e-09	;# [eV cm]
	    set B_n 2.3800e-07	;# [eV cm^(3/4)]
	    set B_p 3.8700e-07	;# [eV cm^(3/4)]
	    set C_n 1.8300e-11	;# [eV cm^(3/2)]
	    set C_p 3.4100e-12	;# [eV cm^(3/2)]
	    set D_n 7.2500e-11	;# [eV cm^(3/2)]
	    set D_p 4.8400e-13	;# [eV cm^(3/2)]

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
GaAs::TableBGN::init
