#----------------------------------------------------------------------#
# $Id: GF.tcl,v 1.1 2022/03/29 20:02:02  Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model from Lumb
#! MATERIAL: InGaAs
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)   
#! Temperature dependence is suppressed by setting alpha=0
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: This model is valid only for T=300K
#! NOTES: Calculates Brad and the photon recycling factor through python, which gives them combined
#! calculating the Brad coefficient using therer formula, which uses nk data
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! Dagan et al. "Minority carrier recombination of ordered GaInP at high temperatures," 2016.
#! Lumb et al. "Incorporating photon recycling into the analytical drift-diffusion model of high efficiency," 2014.
#! created by Gavin Forcade 2022



namespace eval InGaAs::RadiativeRecombination {
    proc init {} {



	#function to interface with python
	proc Brad_python { t l n k Eg T Nc Nv } {
		#INPUT: thickness, nk data path, bandgap, temperature, conduction band DOS, valence band DOS
		set output [exec python ../../../../Python/Brad.py $t $l $n $k $Eg $T $Nc $Nv]
		puts "Brad: $output"
		return $output
	}


	


	# get bandgap from file
	#source ../../../../pardb/InGaAs/BandStructure/Bandgap/Piprek_rev.tcl
	set Eg [evalVar "${::material}::Bandgap::Eg"]

	# get eDOSMass from file
	#source ../../../../pardb/InGaAs/BandStructure/eDOSMass/Ioffe.tcl
	set Nc [evalVar "${::material}::eDOSMass::Nc"]

	# get hDOSMass from file
	#source ../../../../pardb/InGaAs/BandStructure/hDOSMass/Ioffe.tcl
	set Nv [evalVar "${::material}::hDOSMass::Nv"]

	# optical data directory
	#set dataFile ../../../../pardb/InGaAs/Optics/ComplexRefractiveIndex/ISE_ISE/In53GaAs.dat
	set n [evalVar2 "\$${::material}::ComplexRefractiveIndex::nlist"]
	set k [evalVar2 "\$${::material}::ComplexRefractiveIndex::klist"]
	set l [evalVar2 "\$${::material}::ComplexRefractiveIndex::llist"]




	variable C [Brad_python $::thickness $l $n $k $Eg $::temp $Nc $Nv]   
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
InGaAs::RadiativeRecombination::init
