#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2008/07/15 12:46:07 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: GaInP
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
#! This model is valid for both n-GaInP and p-GaInP
#! NOTES: 
#! The model from Piprek is implemented here in the form of TableBGN model. 
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2008/07/15 by Sameer Shah

namespace eval GaInP::TableBGN {
    proc init {} {
# Parameters from Piprek (Table 1.1, page 7 and Table 4.4, page 94)
        set C 3.9e-5
        set B 3.1e12
        set epsilon_InP 12.61
        set mc_InP 0.079     
        set mv_InP 0.60
        set epsilon_GaP 11.10
        set mc_GaP 0.79     
        set mv_GaP 0.83

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

# Since the bowing parameters are not specified in Piprek, linear interpolation between the bandgap narrowing 
# of the side binary materials is used to calculate the bandgap narrowing of GaInP
        set epsilon [expr {[::compute_ternary $::xMole $epsilon_GaP $epsilon_InP]}]
        set mc [expr {[::compute_ternary $::xMole $mc_GaP $mc_InP]}]
        set mv [expr {[::compute_ternary $::xMole $mv_GaP $mv_InP]}]

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
GaInP::TableBGN::init
