* Copyright (c) 1994-2019 Synopsys, Inc.
* This parameter file and the associated documentation are proprietary
* to Synopsys, Inc.  This parameter file may only be used in accordance
* with the terms and conditions of a written license agreement with
* Synopsys, Inc.  All other use, reproduction, or distribution of this
* parameter file is strictly prohibited.
* Quaternary of GaInAsP with interp from Ga0.47In0.53As to InP
* 
* xMole : ___InP____ mole fraction!!




!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material GaInPAs_InP         ; # Specify material name
set VBO [expr {0.0*$::xMole + (0.94-0.59*0.53-0.8*0.47+0.38*0.47*0.53)*(1.0-$::xMole)}]    	; #using Vurgaftmann values



#-----------------------------------------------------
# Input Validation and Header Printing section
#-----------------------------------------------------
# Validate variables and print header section in par file

###source $CWD/../lib/printPar.tcl
printPar::header

#---------------------------------
# Parameter Initialization section
#---------------------------------
# Initialize parameters

initProperty $material Permittivity Epsilon Adachi
initProperty $material BandStructure Bandgap GF_RT

initProperty $material BandStructure eDOSMass GF_RT
initProperty $material BandStructure hDOSMass GF_RT_Piprek
#initProperty $material BandStructure TableBGN GF

# initProperty $material Mobility ConstantMobility Sotoodeh
initProperty $material Mobility DopingDependence GF

set del_k @del_k@
initProperty $material Optics ComplexRefractiveIndex @InGaAs_nk@
##NRC_morphingAlg_GaInAsP_x
# initProperty $material Optics TableODB Schubert

set PR @PR@
initProperty $material Recombination RadiativeRecombination GF_PR
#initProperty $material Recombination Scharfetter GF
initProperty $material Recombination Auger GF
initProperty $material Recombination BarrierTunneling GF
initProperty $material Recombination Band2BandTunneling GF
set S @InGaAs_S@
initProperty $material Recombination TrapAssistedTunneling GF


#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::Bandgap::print
#${material}::TableBGN::print

${material}::eDOSMass::print
${material}::hDOSMass::print

# ${material}::ConstantMobility::print
${material}::DopingDependence::print

${material}::ComplexRefractiveIndex::print
# ${material}::TableODB::print

${material}::RadiativeRecombination::print
#${material}::Scharfetter::print
${material}::Auger::print
${material}::BarrierTunneling::print
${material}::Band2BandTunneling::print
${material}::TrapAssistedTunneling::print
)!


ThermionicEmission {
        Formula=1
	A = 2, 2  # [1]
	B = 4, 4  # [1]
	C = 1, 1  # [1]
} 



Scharfetter * relation and trap level for SRH recombination:
{ * tau = taumin + ( taumax - taumin ) / ( 1 + ( N/Nref )^gamma)
  * tau(T) = tau * ( (T/300)^Talpha )          (TempDep)
  * tau(T) = tau * exp( Tcoeff * ((T/300)-1) ) (ExpTempDep)
	taumin	= 0.0000e+00 ,	0.0000e+00	# [s]
	!( 
	if {$::region == "sc1_em200"} {
	print "taumax	= 1.00e-8 , 1.00e-8		\n"
	} else {
	print "taumax	= @InGaAs_tauSRH@ , @InGaAs_tauSRH@		\n"
	}
	)!		  
	Nref	= 1.0000e+20 ,	1.0000e+20	# [cm^(-3)]
	gamma	= 1 ,	1	# [1]
	Talpha	= 0.0000e+00 ,	0.0000e+00	# [1]
	Tcoeff	= 0.0000e+00 ,	0.0000e+00	# [1]
	Etrap	= 0.0	# [eV]
}





