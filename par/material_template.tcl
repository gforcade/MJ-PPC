!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material <material>         ; # Specify material name
set cbo <cbo>                   ; # Specify cbo value for simulations involving heterostructure and if this material is not the reference material

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

initProperty $material Permittivity Epsilon <model>

initProperty $material BandStructure Bandgap <model>
initProperty $material BandStructure JainRoulston <model>
#initProperty $material BandStructure TableBGN <model>
#initProperty $material BandStructure delAlamo <model>
initProperty $material BandStructure eDOSMass <model>
initProperty $material BandStructure hDOSMass <model>

initProperty $material Quantization SchroedingerParameters <model>

initProperty $material Mobility ConstantMobility <model>
#if {$::doping != 0} {
  initProperty $material Mobility DopingDependence <model> 
#}
initProperty $material Mobility HighFieldDependence <model>

initProperty $material Optics TableODB <model>
initProperty $material Optics FreeCarrierAbsorption <model>
initProperty $material Optics RefractiveIndex <model>

initProperty $material Recombination RadiativeRecombination <model>
initProperty $material Recombination Scharfetter <model>
initProperty $material Recombination Auger <model>
initProperty $material Recombination BarrierTunneling <model>

initProperty $material ThermoTransport Kappa <model>
initProperty $material ThermoTransport LatticeHeatCapacity <model>

initProperty $material Traps PooleFrenkel <model>

#--------------------------------
# Parameter Printing section
#--------------------------------
# print parameter sections in par file

${material}::Epsilon::print

${material}::Bandgap::print
${material}::JainRoulston::print
#${material}::TableBGN::print
#${material}::delAlamo::print
${material}::eDOSMass::print
${material}::hDOSMass::print

${material}::SchroedingerParameters::print

${material}::ConstantMobility::print
${material}::DopingDependence::print
${material}::HighFieldDependence::print

${material}::TableODB::print
${material}::FreeCarrierAbsorption::print
${material}::RefractiveIndex::print

${material}::RadiativeRecombination::print
${material}::Scharfetter::print
${material}::Auger::print
${material}::BarrierTunneling::print

${material}::Kappa::print
${material}::LatticeHeatCapacity::print

${material}::PooleFrenkel::print

)!



