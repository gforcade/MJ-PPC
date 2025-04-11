!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material AlGaInP         ; # Specify material name

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

initProperty $material BandStructure Bandgap Default_4CPV
#initProperty $material BandStructure Bandgap Levinshtein-RT

initProperty $material BandStructure JainRoulston Levinshtein
initProperty $material BandStructure eDOSMass Levinshtein
initProperty $material BandStructure hDOSMass Piprek

initProperty $material Mobility ConstantMobility Sotoodeh
# initProperty $material Mobility DopingDependence Sotoodeh_4CPV

# initProperty $material Optics TableODB Default_4CPV
# initProperty $material Optics TableODB Walker_T
initProperty $material Optics ComplexRefractiveIndex Schubert_MDF

initProperty $material Recombination RadiativeRecombination Levinshtein
initProperty $material Recombination Scharfetter Default
initProperty $material Recombination Auger Levinshtein_4CPV


#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::Bandgap::print
${material}::JainRoulston::print

${material}::eDOSMass::print
${material}::hDOSMass::print

${material}::ConstantMobility::print

${material}::ComplexRefractiveIndex::print

${material}::RadiativeRecombination::print
${material}::Scharfetter::print
${material}::Auger::print
)!

