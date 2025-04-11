!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material InAlAs         ; # Specify material name
set VBO [expr {0.94-0.59*$::xMole-1.33*(1.0-$::xMole)+0.64*($::xMole)*(1.0-$::xMole)}]
#puts stderr "InGaAsN::VBO=$VBO for mole fraction $::xMole"
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

initProperty $material BandStructure Bandgap Adachi
initProperty $material BandStructure TableBGN MB
initProperty $material BandStructure JainRoulston GF
initProperty $material BandStructure eDOSMass Vurgaftman
initProperty $material BandStructure hDOSMass Piprek



initProperty $material Mobility ConstantMobility Lumb
initProperty $material Mobility DopingDependence Lumb 


initProperty $material Optics ComplexRefractiveIndex Dinges_GF

initProperty $material Recombination Auger Default
initProperty $material Recombination RadiativeRecombination MB
initProperty $material Recombination Scharfetter MB

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Bandgap::print
${material}::JainRoulston::print
${material}::TableBGN::print
${material}::eDOSMass::print
${material}::hDOSMass::print



${material}::ConstantMobility::print
${material}::DopingDependence::print

${material}::ComplexRefractiveIndex::print

${material}::Auger::print
${material}::RadiativeRecombination::print
${material}::Scharfetter::print

)!



Epsilon
{ *  Ratio of the permittivities of material and vacuum
  * epsilon() = epsilon
  # Valid on for In52AlAs.
  # Reference: Springer Handbook of Electronic and Photonic Materials 2nd edition (ch. 30 - Adachi)
  # Linear interpolation between InAs (14.3) and AlAs (10.06)
	epsilon	= 12.3	#adachi
}


BarrierTunneling  
{ * Non Local Barrier Tunneling 
  * G(r) = g*A*T/kB*F(r)*Pt(r)*ln[(1+exp((E(r)-Es)/kB/T))/(1+exp((E(r)-Em)/kB/T))]
  * where: 
  *     Pt(r) is WKB approximation for the tunneling probability 
  *     g = As/A, As is the Richardson constant for carriers in semiconductor
  *     A is the Richardson constant for free electrons 
  *     F(r) is the electric field 
  *     E(r) is carrier energy 
  *     Es is carrier quasi fermi energy in semiconductor
  *     Em is carrier fermi energy in metal 
  *	mt	= 0.069 ,	0.68	# [1]	#from Adachi 2009, Piprek 2003
	mt	= 0.069 ,	0.093 	#[1]	#from Adachi 2009
	g	= 2     ,	4
}



TrapAssistedTunneling { 
*see manual Trap-assisted tunneling/SRH
	S 		= 6.8		# [1]
	hbarOmega 	= 0.04 		# [eV]
	MinField	= 1e3		# [V/cm]
	m_theta		= 0.069 , 0.093	# [1]
}


Band2BandTunneling 
{ * Non Local Barrier Tunneling
  * G(r) = grad(E(r))*g*pi/36h*Int(dr/k)^(-1)(1.....
	m_c = 0.069	#[m0]
*	m_v = 0.6	#[m0]
	m_v = 0.093	#[m0]
	degeneracy = 2	#[1]
	Ppath = 0	#[1]
	maxTunnelLength = 10e-7 #[cm]
}



ThermionicEmission {
        Formula=1
	A = 2, 2  # [1]
	B = 4, 4  # [1]
	C = 1, 1  # [1]
}


MultiValley 
{  	
* here to model with nonparabolic bands

* calculate alpha. delta is the split-off band energy, Eg is bandgap energy (both in eV)

	


* using alpha =  Eg x 0.9


	eValley"Gamma"(m=0.069 energy=0.0 alpha=0.62 degeneracy=2.0 xid=-10.20)
} 



