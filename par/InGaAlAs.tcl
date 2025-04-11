!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material InGaAs_InAlAs         ; # Specify material name
set VBO [expr (0.94-0.59*0.53-0.8*(1.0-0.53)+0.38*(1.0-0.53)*0.53)*$::xMole + (0.94-0.59*0.52-1.33*(1.0-0.52)+0.64*(0.52)*(1.0-0.52))*(1.0-$::xMole)]


#Ref: Levinshtein
    
#-----------------------------------------------------
# Input Validation and Header Printing section
#-----------------------------------------------------
# Validate variables and print header section in par file

##source $CWD/../lib/printPar.tcl
printPar::header

#---------------------------------
# Parameter Initialization section
#---------------------------------
# Initialize parameters

initProperty $material BandStructure Bandgap Piprek_rev
##Piprek_rev
# initProperty $material BandStructure TableBGN MB
#initProperty $material BandStructure JainRoulston Li
initProperty $material BandStructure hDOSMass Piprek
initProperty $material BandStructure eDOSMass Ioffe

#initProperty $material Mobility ConstantMobility Sotoodeh
initProperty $material Mobility DopingDependence Sotoodeh 


initProperty $material Optics ComplexRefractiveIndex @InGaAs_nk@


initProperty $material Recombination Auger Levinshtein

#use photon recycling or don't with on or off
set PR @PR@
initProperty $material Recombination RadiativeRecombination Levinshtein

#initProperty $material Recombination Scharfetter Ahrenkiel

initProperty $material Recombination Band2BandTunneling GF

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Bandgap::print
#${material}::JainRoulston::print
# ${material}::TableBGN::print
${material}::eDOSMass::print
${material}::hDOSMass::print

#${material}::ConstantMobility::print
${material}::DopingDependence::print

${material}::ComplexRefractiveIndex::print



${material}::Auger::print
${material}::RadiativeRecombination::print
#${material}::Scharfetter::print
${material}::Band2BandTunneling::print

)!





Epsilon
{ *  Ratio of the permittivities of material and vacuum
  * epsilon() = epsilon
  # Valid on for In53GaAs.
  # Reference: Ioffe
*	epsilon	= 13.9 #Ioffe
	epsilon = 13.6 #adachi
}


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
	taumax	= @InGaAs_tauSRH@ , @InGaAs_tauSRH@		# [s]			##Ahrenkiel et al. "Recombination lifetime of InGaAs as a function of doping", 1998.  
	Nref	= 1.0000e+20 ,	1.0000e+20	# [cm^(-3)]
	gamma	= 1 ,	1	# [1]
	Talpha	= 0.0000e+00 ,	0.0000e+00	# [1]
	Tcoeff	= 0.0000e+00 ,	0.0000e+00	# [1]
	Etrap	= 0.0	# [eV]
}


MultiValley 
{  	
* here to model with nonparabolic bands

* calculate alpha. delta is the split-off band energy, Eg is bandgap energy (both in eV)

	

* using alpha =  1/Eg x 0.9

	eValley"Gamma"(m=0.040887 energy=0.0 alpha=1.22 degeneracy=2.0 xid=-10.20)
} 



HurkxTrapAssistedTunneling 
{ *band to band tunneling with assistance from traps. We only need the effective tunneling mass mt

	mt = 0.041, 0.0528

}


TrapAssistedTunneling {
 *see manual Trap-assisted tunneling/SRH
	S 		= @InGaAs_S@		# [1]
	hbarOmega 	= 0.03 		# [eV] # Schenk et al, "Tunneling between density of state tails: ...", 2020.
	MinField	= 1e3		# [V/cm]
	m_theta		= 0.041 , 0.0528	# [1]
}


SurfaceRecombination {
* see manual for surface recombination params 
	S0 		= 0.0,  0.0	# [cm/s]
	Sref	 	= 0.0 				# [1]
	Nref		= 1e3				# [cm-3]
	gamma		= 1.0 				# [1]
	Etrap		= 0.0				# [eV]
}




