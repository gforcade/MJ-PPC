!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material MQW_eff         ; # Specify material name

#-----------------------------------------------------
# Input Validation and Header Printing section
#-----------------------------------------------------
# Validate variables and print header section in par file

source ../lib/printPar.tcl
printPar::header

#---------------------------------
# Parameter Initialization section
#---------------------------------
# Initialize parameters

initProperty $material Permittivity Epsilon Default
initProperty $material BandStructure Bandgap Default
#initProperty $material BandStructure JainRoulston Default
#initProperty $material BandStructure TableBGN Schubert
initProperty $material BandStructure eDOSMass Default
initProperty $material BandStructure hDOSMass Default

initProperty $material Mobility ConstantMobility Default
initProperty $material Mobility DopingDependence Default

initProperty $material Optics ComplexRefractiveIndex Constant_alpha

initProperty $material Recombination RadiativeRecombination Default
initProperty $material Recombination Scharfetter Default
# initProperty $material Recombination Auger Levinshtein

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::Bandgap::print
${material}::eDOSMass::print
${material}::hDOSMass::print

${material}::ConstantMobility::print
${material}::DopingDependence::print
${material}::ComplexRefractiveIndex::print
${material}::RadiativeRecombination::print
${material}::Scharfetter::print
# ${material}::Auger::print


)!

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
	mt	= 0.05 ,	0.14	# [1]	
	g	= 0.21 ,	0.4
}
 

