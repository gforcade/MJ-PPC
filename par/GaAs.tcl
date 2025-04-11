!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material GaAs         ; # Specify material name

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

initProperty $material Permittivity Epsilon Piprek_4CPV
initProperty $material BandStructure Bandgap Default_4CPV
#initProperty $material BandStructure JainRoulston Default
initProperty $material BandStructure TableBGN Schubert
initProperty $material BandStructure eDOSMass Levinshtein_4CPV
initProperty $material BandStructure hDOSMass Levinshtein_4CPV
initProperty $material Quantization SchroedingerParameters Default

initProperty $material Mobility ConstantMobility Sotoodeh

initProperty $material Mobility DopingDependence Sotoodeh-Masetti_4CPV

initProperty $material Mobility HighFieldDependence Default-TEM2

initProperty $material Optics ComplexRefractiveIndex Adachi

initProperty $material Recombination RadiativeRecombination Piprek_4CPV
initProperty $material Recombination Scharfetter Default_4CPV
initProperty $material Recombination Auger Levinshtein_4CPV

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::Bandgap::print
#${material}::JainRoulston::print
${material}::TableBGN::print
${material}::eDOSMass::print
${material}::hDOSMass::print
${material}::SchroedingerParameters::print

${material}::ConstantMobility::print
${material}::DopingDependence::print
${material}::HighFieldDependence::print

${material}::ComplexRefractiveIndex::print

${material}::RadiativeRecombination::print
${material}::Scharfetter::print
${material}::Auger::print


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
 

