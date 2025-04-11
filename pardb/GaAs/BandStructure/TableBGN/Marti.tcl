#----------------------------------------------------------------------#
# $Id: Marti.tcl,v 1.4 2008/03/28 06:00:41 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Bandgap Narrowing (BGN) model from Marti, implemented using TableBGN model
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing 
#! EXPRESSION: 
#! Bandgap narrowing  is calculated using, 
#! deltaEg = (0.125/epsilon)*|1-N/Ncr|^(1/3)  for n-GaAs and N > Ncr
#! deltaEg = (0.11/epsilon)*|1-N/Ncr|^(1/3)  for n-GaAs and N > Ncr
#! where,
#! Ncr=1.6e24(me/(1.4 epsilon))^3
#! CALCULATED PARAMETER:
#! Eref returns deltaEg
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! NOTES:
#! The model from Marti is implemented here in the form of TableBGN model. 
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! Marti, 1992

namespace eval GaAs::TableBGN {
    proc init {} {
        variable Na
        variable Nd
        variable deltaEg_n
        variable deltaEg_p
      
# Create lists of Na and Nd
        set N 10
        # N = number of linearly spaced elements in a decade interval
        set min 1e16
        set max 1e20
        set Nd_tmp [decadelinspace $min $max $N]
        set Na_tmp $Nd_tmp
# Calculate deltaEg using Marti's model        
    	set me 0.066
    	set epsilon [expr {12.4*(1.0 + 1.2e-4*$::temp)}]
    	set Ncr [expr {1.6e24*pow($me/(1.4*$epsilon),3)}]
  
        set deltaEg_n [list]
        set Nd [list]
        foreach dopingN $Nd_tmp {
            set k [expr ($dopingN>$Ncr)]
            if { $dopingN > $Ncr } {                           
                set deltaEgn [expr {(0.125/$epsilon)*pow([expr abs(1- $dopingN/$Ncr)], 1.0/3.0)}]
                lappend deltaEg_n $deltaEgn
                lappend Nd $dopingN
           }
       }
       set deltaEg_p [list]
       set Na [list] 
       foreach dopingP $Na_tmp {
            if { $dopingP > $Ncr } {                                          
                set deltaEgp [expr {(0.11/$epsilon)*pow([expr abs(1- $dopingN/$Ncr)], 1.0/3.0)}]
                lappend deltaEg_p $deltaEgp
                lappend Na $dopingP
           }
       }

       
}
    proc print {} {printPar::TableBGNSection}
}
GaAs::TableBGN::init
