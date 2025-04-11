#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2021/11/19 G Forcade $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: Ga(y)In(1-y)P(x)As(1-x) lattice matched to InP
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)   
#! Temperature dependence is suppressed by setting alpha=0
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: This model is valid for all temperatures, but would need to use temperature dependent bandgap
#! NOTES: 
#! Using the radiative recombination coefficient equation from the reference below
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! A. Dmitriev, "Recombination and Ionization in narrow gap semiconductors", 1995
#! created by Gavin Forcade 2021/11/19

namespace eval GaInPAs_InP::RadiativeRecombination {
    proc init {} {


#boltzmann constant 
	set kB 8.53e-5  ;# [eV/K]


## grabbing variables from using internal files. To use to calculate radiative recombination
#run the file 
source ../../lib/helper.tcl
#get bandgap from file
source ../GaInPAs_InP/BandStructure/Bandgap/GF_RT.tcl
set Eg [evalVar "${::material}::Bandgap::Eg"]
#get electron effective mass
source ../GaInPAs_InP/BandStructure/eDOSMass/GF_RT.tcl
set me [evalVar "${::material}::eDOSMass::mm"]
#get heavy hole effective mass
source ../GaInPAs_InP/BandStructure/hDOSMass/GF_RT_Piprek.tcl
set mhh [evalVar "${::material}::hDOSMass::mhh"]
#get optical permittivity
source ../GaInPAs_InP/Permittivity/Epsilon_inf/Piprek.tcl
set epsilon_inf [evalVar "${::material}::Epsilon_inf::epsilon_inf"]



#equation for the rediative recombination coefficient
	variable C 
	set C1 [expr {5.8e-13*pow($epsilon_inf,1.0/2.0)*pow(1.0/($me + $mhh),3.0/2.0)*(1.0 + 1.0/$me)*pow(300.0/$::temp,3.0/2.0)}]
	set C2 [expr {$Eg*$Eg + 3.0*$kB*$::temp*$Eg + 3.75*$kB*$kB*$::temp*$::temp}]
	set C [expr {$C1*$C2}]
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
GaInPAs_InP::RadiativeRecombination::init
