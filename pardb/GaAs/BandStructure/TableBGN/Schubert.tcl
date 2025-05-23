#----------------------------------------------------------------------#
# $Id: Schubert.tcl,v 1.3 2008/03/28 06:00:41 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Bandgap Narrowing (BGN) model from Schubert
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing 
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors
#! deltaEg_p return BGN for acceptors
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! NOTES: Schubert's model is implemented here in the form of TableBGN model.
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! E.F.Schubert, Physical Foundations of Solid-State Devices, 2006

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
        
# Parameters from Schubert
	   variable A_n 6.6e-8	;# [eV cm]
       variable A_p 2.4e-8	;# [eV cm]
	   variable B_n 0.0	    ;# [eV cm^(3/4)]
	   variable B_p 0.0	    ;# [eV cm^(3/4)]
	   variable C_n 0.0     ;# [eV cm^(3/2)]
	   variable C_p 0.0	    ;# [eV cm^(3/2)]
	   variable D_n 0.0	    ;# [eV cm^(3/2)]
	   variable D_p 0.0	    ;# [eV cm^(3/2)]

# Calculate deltaEg using Schubert model
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
