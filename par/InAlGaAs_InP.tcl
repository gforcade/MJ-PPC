!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material InAlGaAs_InP         ; # Specify material name

#-----------------------------------------------------
# Input Validation and Header Printing section
#-----------------------------------------------------
# Validate variables and print header section in par file

source $CWD/../lib/printPar.tcl
printPar::header

#---------------------------------
# Parameter Initialization section
#---------------------------------
# Initialize parameters

initProperty $material BandStructure Bandgap MB
initProperty $material BandStructure eDOSMass MB
initProperty $material BandStructure hDOSMass MB

initProperty $material Mobility ConstantMobility MB
#initProperty $material Mobility DopingDependence Default 
initProperty $material Mobility DopingDependence MB

initProperty $material Optics ComplexRefractiveIndex SUNLAB

initProperty $material Recombination Auger Default
initProperty $material Recombination RadiativeRecombination MB
initProperty $material Recombination Scharfetter MB

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Bandgap::print
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
{ 
  * Ratio of the permittivities of material and vacuum
  * epsilon() = epsilon

	epsilon(0)	= 13.9	# [1] # [05Ada]
  	epsilon(1)	= 12.3	# [1] # [05Ada]
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
	mt	= 0.05 ,	0.14	# [1]	#Values for GaAs
	g	= 0.21 ,	0.4
}

Bennett
{ * deltaEg = dEg0 + Ebgn (ln(N/Nref))^2
  * dEg0 is defined in BandGap section 
	Ebgn	= @E_bgn@	# [eV]
	Nref	= 1.0e+15	# [cm^(-3)]
}


