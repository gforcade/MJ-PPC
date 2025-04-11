#----------------------------------------------------------------------#
# $Id: GF.tcl,v 1.1 2022/03/29 20:02:02  Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model from Lumb
#! MATERIAL: GaInAsP_InP 
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)   
#! Temperature dependence is suppressed by setting alpha=0
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: This model is valid only for T=300K
#! NOTES: Calculates Brad and the photon recycling factor through python, which gives them combined
#! calculating the Brad coefficient using there formula, which uses nk data. Turn on photon recycling by passing PR="ON"
#!
#! Is general for any material. Just change the material name after eval and the last line.
#! 
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! Dagan et al. "Minority carrier recombination of ordered GaInP at high temperatures," 2016.
#! Lumb et al. "Incorporating photon recycling into the analytical drift-diffusion model of high efficiency," 2014.
#! created by Gavin Forcade 2022



namespace eval GaInPAs_InP::RadiativeRecombination {
    proc init {} {



	#function to interface with python
	proc Brad_python { t l n k l_sub n_sub Eg T Nc Nv PR Bfactor} {
		#INPUT: thickness, nk data path, bandgap, temperature, conduction band DOS, valence band DOS
		set output [exec python ../../../../Python/Brad_PR.py $t $l $n $k $l_sub $n_sub $Eg $T $Nc $Nv $PR]
		puts "Brad: $output*$Bfactor"
		return [expr $output*$Bfactor] 
	}


	


	# get bandgap from file
	set Eg [evalVar "${::material}::Bandgap::Eg"]

	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]

	# get hDOSMass from file
	set Nv [evalVar "${::material}::hDOSMass::Nv"]

	# optical data for InGaAs
	set n [evalVar2 "\$${::material}::ComplexRefractiveIndex::nlist"]
	set k [evalVar2 "\$${::material}::ComplexRefractiveIndex::klist"]
	set l [evalVar2 "\$${::material}::ComplexRefractiveIndex::llist"]

	# optical data for substrate. Assume 1.0 (to make it like the backside with reflect everything)
	if {$::substrate_t > 0.0 } {
	set n_sub [evalVar2 "\$${::substrate}::ComplexRefractiveIndex::nlist"]
	set l_sub [evalVar2 "\$${::substrate}::ComplexRefractiveIndex::llist"]
	} else {
	set n_sub [list 1.0 1.0]
	set l_sub [list 1.0 1.8]
	}



	variable C [Brad_python $::thickness $l $n $k $l_sub $n_sub $Eg $::temp $Nc $Nv $::PR $::InGaAs_Bfactor]   
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
GaInPAs_InP::RadiativeRecombination::init
