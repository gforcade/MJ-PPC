!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material InP         ; # Specify material name

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

initProperty $material Permittivity Epsilon Adachi
initProperty $material BandStructure Bandgap Piprek
initProperty $material BandStructure JainRoulston Li
initProperty $material BandStructure TableBGN GF
initProperty $material BandStructure eDOSMass Piprek-RT
initProperty $material BandStructure hDOSMass Piprek
#initProperty $material Quantization SchroedingerParameters Default

initProperty $material Mobility ConstantMobility Sotoodeh

initProperty $material Mobility DopingDependence Sotoodeh

#initProperty $material Mobility HighFieldDependence Default-TEM2

initProperty $material Optics ComplexRefractiveIndex Palik-Aspnes

initProperty $material Recombination RadiativeRecombination Piprek
initProperty $material Recombination Scharfetter GF
initProperty $material Recombination Auger GF

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::Bandgap::print
${material}::JainRoulston::print
${material}::TableBGN::print
${material}::eDOSMass::print
${material}::hDOSMass::print
#${material}::SchroedingerParameters::print

${material}::ConstantMobility::print
${material}::DopingDependence::print
#${material}::HighFieldDependence::print

${material}::ComplexRefractiveIndex::print

${material}::RadiativeRecombination::print
${material}::Scharfetter::print
${material}::Auger::print


)!


ThermionicEmission {
        Formula=1
	A = 2, 2  # [1]
	B = 4, 4  # [1]
	C = 1, 1  # [1]
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
	mt	= 0.079 ,	0.12	# [1]	#Values for InP
	g	= 2    ,	2		#values for band degeneracy
}


Band2BandTunneling 
{ * Non Local Barrier Tunneling
  * G(r) = grad(E(r))*g*pi/36h*Int(dr/k)^(-1)(1.....
	m_c = 0.079	#[m0]
*	m_v = 0.56	#[m0]
	m_v = 0.12	#[m0]
	degeneracy = 4	#[1]
	Ppath = 0	#[1]
	maxTunnelLength = 10e-7 #[cm]
}



TrapAssistedTunneling {
 *see manual Trap-assisted tunneling/SRH
	S 		= 6.8		# [1]
	hbarOmega 	= 0.04 		# [eV]
	MinField	= 1e3		# [V/cm]
	m_theta		= 0.079 , 0.12	# [1]
}





MultiValley 
{  	
* here to model with nonparabolic bands

* calculate alpha. delta is the split-off band energy, Eg is bandgap energy (both in eV)

	


* using alpha =  Eg x 0.9


	eValley"Gamma"(m=0.079 energy=0.0 alpha=0.67 degeneracy=2.0 xid=-10.20)
} 


