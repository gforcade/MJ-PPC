#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.4 2008/07/15 12:44:22 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: AlGaAs
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
#! This model is valid for both n-AlGaAs and p-AlGaAs
#! NOTES: 
#! The model from Piprek is implemented here in the form of TableBGN model. 
#! Use this model for regions with non-uniform doping profiles.
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2007/08/31 by Sameer Shah

namespace eval AlGaAs::TableBGN {
    proc init {} {
# Parameters from Piprek (Table 1.1, page 7 and Table 4.4, page 94)
        set C 3.9e-5
        set B 3.1e12
        set epsilon_GaAs 12.91
        set mc_GaAs 0.063     
        set mv_GaAs 0.52
        set epsilon_AlAs 10.06
        set mc_AlAs 0.79     
        set mv_AlAs 0.8

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
# of the side binary materials is used to calculate the bandgap narrowing of AlGaAs
        set epsilon [expr {[::compute_ternary $::xMole $epsilon_AlAs $epsilon_GaAs]}]
        set mc [expr {[::compute_ternary $::xMole $mc_AlAs $mc_GaAs]}]
        set mv [expr {[::compute_ternary $::xMole $mv_AlAs $mv_GaAs]}]

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
AlGaAs::TableBGN::init
