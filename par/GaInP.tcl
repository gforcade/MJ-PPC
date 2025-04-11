!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material GaInP         ; # Specify material name
set VBO -0.31          ; # Specify cbo value for simulations involving heterostructure and if this material is not the substrate material
puts stderr "GaInP::VBO=$VBO"
# Ref: Vurgaftmann 

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

initProperty $material Permittivity Epsilon Piprek
initProperty $material BandStructure Bandgap Default_4CPV

initProperty $material BandStructure eDOSMass Levinshtein
initProperty $material BandStructure hDOSMass Piprek
initProperty $material BandStructure TableBGN Piprek

initProperty $material Mobility ConstantMobility Sotoodeh
initProperty $material Mobility DopingDependence Sotoodeh

initProperty $material Optics ComplexRefractiveIndex Schubert_MDF
# initProperty $material Optics TableODB Schubert

initProperty $material Recombination RadiativeRecombination Levinshtein
initProperty $material Recombination Scharfetter Default
initProperty $material Recombination Auger Levinshtein


#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::Bandgap::print
${material}::TableBGN::print

${material}::eDOSMass::print
${material}::hDOSMass::print

${material}::ConstantMobility::print
${material}::DopingDependence::print

${material}::ComplexRefractiveIndex::print
# ${material}::TableODB::print

${material}::RadiativeRecombination::print
${material}::Scharfetter::print
${material}::Auger::print
)!

SchroedingerParameters {
	Formula = 2
}

BarrierTunneling  
{ * Non Local Barrier Tunneling 
  * G(r) = g*A*T/kB*F(r)*Pt(r)*ln[(1+exp((E(r)-Es)/kB/T))/(1+exp((E(r)-Em)/kB/T))]
  * where: 
  *     Pt(r) is WKB approximation for the tunneling probability 
  *     g = As/A                 As is the Richardson constant for carriers in semiconductor
  *     A is the Richardson constant for free electrons 
  *     F(r) is the electric field 
  *     E(r) is carrier energy 
  *     Es is carrier quasi fermi energy in semiconductor
  *     Em is carrier fermi energy in metal 
#	mt	= GaInP_mte_NLM, GaInP_mth_NLM	# [1]	
	mt	= 0.24 ,              0.48	# [1]	
	g = 0.21 , 0.4
}


Band2BandTunneling {
	MaxTunnelLength=15e-7 # [cm]
}

