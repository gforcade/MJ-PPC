#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.2 2021/12/10 12:01:08 Gavin Forcade Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: InP
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format. 
#! The n-InP bandgap reduction is calculated using the following formula
#! deltaEg = K*N^(1/3)
#! where K is a fit parameter, N is the doping concentration
#! The p-InP bandgap reduction is calculated using the following universal fit formula
#! deltaEg = -C*((epsilon^5/N)*(m0*(mc+mv)/(mc*mv) + B*T^2*epsilon/N))^(-1/4)
#! where C and B are fit parameters, epsilon is the static dielectric constant, N is the doping concentration, m0 is 
#! the free electron mass, mc and mv are conduction and valence band density of states effective mass and T is the 
#! temperature
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors in [eV]
#! deltaEg_p return BGN for acceptors in [eV]
#! VALIDITY: 
#! This file is valid for n-InP and p-InP
#! NOTES: 
#! The curve fit to n-InP experimental data
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! "Reabsorption, band-gap narrowing, and the reconciliation of photoluminescence spectra with electrical measurements for epitacial n-InP", Sieg, J. A. P., 1996
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2021/12/10 by Gavin Forcade - uOttawa SUNLAB

namespace eval InP::TableBGN {
    proc init {} {
# Parameters from Piprek (Table 1.1, page 7 and Table 4.4, page 94)
        set C 3.9e-5
        set B 3.1e12
        set epsilon 12.61
        set mc 0.079
        set mv 0.60

# Parameter from Sieg [eV cm]
	# includes carrier-carrier and carrier-ion interaction effects (good for BGN at brillouin zone center)
	set K 7.14e-8
	# Only carrier-carrier interaction (good for BGN at fermi level)
#	set K 2.25e-8

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
            set deltaEgn [expr {$K*pow($doping,1.0/3.0)}]
		lappend deltaEg_n $deltaEgn
            	lappend deltaEg_p $deltaEg
	}
    }
    proc print {} {printPar::TableBGNSection}
}
InP::TableBGN::init
