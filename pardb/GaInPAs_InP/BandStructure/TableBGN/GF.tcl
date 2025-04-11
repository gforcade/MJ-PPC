#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.2 2021/11/30 12:01:08 G Forcade Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: GaInPAs_InP
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
#! This model is valid for both n-GaInPAs and p-GaInPAs
#! NOTES: 
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2021/11/30 by Gavin Forcade

namespace eval GaInPAs_InP::TableBGN {
    proc init {} {


## grabbing variables from internal files. To use to calculate 
#get electron effective mass
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	set mc [expr pow($Nc/2.54e19,2.0/3.0)]
#get heavy hole effective mass
	set Nv [evalVar "${::material}::hDOSMass::Nv"]
	set mv [expr pow($Nv/2.54e19,2.0/3.0)]
#get static permittivity
	set epsilon [evalVar "${::material}::Epsilon::epsilon"]


# Parameters from Piprek 
        set C 3.9e-5
        set B 3.1e12

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
set deltaEg_n [expr {$C*(pow((pow($epsilon,5.0)/$::doping)*(($mc+$mv)/($mc*$mv) + $B*$::temp*$::temp*$epsilon/$::doping), -1.0/4.0))}]          

if 0 {
        variable deltaEg_p [list]
        foreach doping $Nd {
            set deltaEg [expr {$C*(pow((pow($epsilon,5.0)/$doping)*(($mc+$mv)/($mc*$mv) + $B*$::temp*$::temp*$epsilon/$doping), -1.0/4.0))}]          
            lappend deltaEg_n $deltaEg
            lappend deltaEg_p $deltaEg
	}
}
    }
    proc print {} {printPar::TableBGNSection}
}
GaInPAs_InP::TableBGN::init
