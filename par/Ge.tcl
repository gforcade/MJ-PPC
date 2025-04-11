!(
#---------------------
# Variable Definitions
#---------------------
set material Ge         ; # Specify material name
# set cbo <value>          ; # Specify cbo value for simulations involving heterostructure and if this material is not the substrate material


#-----------------------------------------------------
# Input Validation and Header Printing section
#-----------------------------------------------------
# Validate variables and print header section in par file

source ../lib/printPar.tcl
printPar::header

#-------------------------------------
# Parameter Initialization section
#-------------------------------------
# Initialize parameters

initProperty $material Permittivity Epsilon Default
initProperty $material Optics RefractiveIndex Default

initProperty $material Optics ComplexRefractiveIndex Palik

initProperty $material BandStructure Bandgap Default
initProperty $material BandStructure TableBGN Piprek

initProperty $material BandStructure eDOSMass Piprek
initProperty $material BandStructure hDOSMass Levinshtein

initProperty $material Mobility ConstantMobility Palankovski

initProperty $material Mobility DopingDependence Palankovski 

initProperty $material Recombination RadiativeRecombination Levinshtein
initProperty $material Recombination Scharfetter Levinshtein
initProperty $material Recombination Auger Levinshtein
initProperty $material Recombination BarrierTunneling Default

#--------------------------------
# Parameter Printing section
#--------------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::RefractiveIndex::print

${material}::Bandgap::print
${material}::TableBGN::print
${material}::eDOSMass::print
${material}::hDOSMass::print

${material}::ConstantMobility::print
${material}::DopingDependence::print

${material}::RadiativeRecombination::print
${material}::Scharfetter::print
${material}::Auger::print

${material}::BarrierTunneling::print

${material}::ComplexRefractiveIndex::print


)!

