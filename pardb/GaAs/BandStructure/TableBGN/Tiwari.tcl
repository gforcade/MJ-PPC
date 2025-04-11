#----------------------------------------------------------------------#
# $Id: Tiwari.tcl,v 1.3 2008/03/28 06:50:18 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Bandgap Narrowing model from Tiwari
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors
#! deltaEg_p return BGN for acceptors
#! VALIDITY: 
#! This model is valid only for p-GaAs
#! NOTES: Levinshtein's model is implemented here in the form of TableBGN model.
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! S.Tiwari and S.L.Wright, "Material properties of p-type GaAs at large dopings," vol.56, no. 6, pp.563-565, 1990 
#! HISTORY:
#! Created on 2007/08/29 by Sameer Shah

namespace eval GaAs::TableBGN {
    proc init {} {
	    variable Na
	    variable Nd
	    variable deltaEg_p
        variable deltaEg_n
    	if { $::doping > 0.0 } {
	        puts stderr "GaAs:TableBGN:Levinshtein: The BGN model from Levinshtein is valid only for p-GaAs. Please use another BGN model!"
            exit -1	    	   
	    } 
            
# Create lists of doping concentration 
# Method I:   
        if 0 {
        set N 60
        set min 1.0e15
        set max 1.0e20
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
	   variable A_n 0.0				;# [eV cm]
       variable A_p 0.0				;# [eV cm]
	   variable B_n 0.0				;# [eV cm^(3/4)]
	   variable B_p 0.0				;# [eV cm^(3/4)]
	   variable C_n 0.0        		;# [eV cm^(3/2)]
	   variable C_p 2.0000e-11      ;# [eV cm^(3/2)]
	   variable D_n 0.0				;# [eV cm^(3/2)]
	   variable D_p 0.0				;# [eV cm^(3/2)]
    
# Calculate deltaEg using Levinshtein model
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
