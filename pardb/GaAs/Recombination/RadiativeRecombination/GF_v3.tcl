#----------------------------------------------------------------------#
# $Id: GF.tcl,v 1.1 2022/03/29 20:02:02  Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: InGaAs
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)   
#! Temperature dependence is suppressed by setting alpha=0
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: This model is valid only for T=300K
#! NOTES: 
#! calculating the Brad coefficient using therer formula, which uses nk data
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! Dagan et al. "Minority carrier recombination of ordered GaInP at high temperatures," 2016.
#! created by Gavin Forcade 2022



namespace eval GaAs::RadiativeRecombination {
    proc init {} {

	source ../../lib/helper.tcl

	#function to interface with python
	proc call_python { t nkDataFile Eg T Nc Nv } {
		#INPUT: thickness, nk data path, 
		set output [exec python ../../lib/Brad_PR.py $t $nkDataFile $Eg $T $Nc $Nv]
		return $output
	}


	


	#get bandgap from file
	source ../../pardb/GaAs/BandStructure/Bandgap/Piprek.tcl
	set Eg [evalVar "${::material}::Bandgap::Eg"]

	#get eDOSMass from file
	source ../../pardb/GaAs/BandStructure/eDOSMass/Piprek.tcl
	set Nc [evalVar "${::material}::eDOSMass::Nc"]

	#get hDOSMass from file
	source ../../pardb/GaAs/BandStructure/hDOSMass/Piprek.tcl
	set Nv [evalVar "${::material}::hDOSMass::Nv"]



	# optical data directory
	set dataFile ../../pardb/GaAs/Optics/ComplexRefractiveIndex/Adachi/GaAs.dat



	variable C [call_python $::thickness $dataFile $Eg $::temp $Nc $Nv]   
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
GaAs::RadiativeRecombination::init
