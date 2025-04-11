#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.4 2008/07/15 12:01:08 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: Ge
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format. For both n and p-type semiconductors,
#! the bandgap reduction is calculated using the following universal fit formula
#! deltaEg = -C*((epsilon^5/N)*(m0*(mc+mv)/(mc*mv) + B*T^2*epsilon/N))^(-1/4)
#! where C and B are fit parameters, epsilon is the static dielectric constant, N is the doping concentration, m0 is 
#! the free electron mass, mc and mv are conduction and valence band density of states effective mass and T is the 
#! temperature
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors in [eV]
#! deltaEg_p return BGN for acceptors in [eV]
#! VALIDITY: 
#! This model is valid for both n-Ge and p-Ge
#! NOTES: 
#! The model from Piprek is implemented here in the form of TableBGN model. 
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2007/08/31 by Sameer Shah

namespace eval Ge::TableBGN {
    proc init {} {
# Parameters from Piprek (Table 1.1, page 7)
        set C 3.9e-5
        set B 3.1e12
        set epsilon 15.8    ;# Since no value for epsilon is defined in Piprek, Sentaurus Device default value is used
        set mc 0.22     
        set mv 0.34

# Create lists of doping concentration 
    # Method I:   
        if 0 {
        set N 60
        set min 1.0e15
        set max 1.0e20
        variable Nd [logspace $min $max $N]
        variable Na [logspace $min $max $N]
        }   
    # Method II: Create Na={1,2,3,...,9,10,20,30,...,90,100,200,300,...,900,1000}     
	set N 20
	# N = number of linearly spaced elements in a decade interval
	set min 1e15
	set max 1e20
	variable Nd [decadelinspace $min $max $N]
	variable Na $Nd
        
# Calculate deltaEg using the universal fit formula from Piprek
        variable deltaEg_n [list]
        variable deltaEg_p [list]
        foreach doping $Nd {
            set deltaEg [expr {$C*(pow((pow($epsilon,5.0)/$doping)*(($mc+$mv)/($mc*$mv) + $B*$::temp*$::temp*$epsilon/$doping), -1.0/4.0))}]          
            lappend deltaEg_n $deltaEg
            lappend deltaEg_p $deltaEg
	}
    }
    proc print {} {printPar::TableBGNSection}
}
Ge::TableBGN::init
