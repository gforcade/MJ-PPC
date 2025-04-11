!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material AlInP         ; # Specify material name
set VBO -0.467          ; # Specify cbo value for simulations involving heterostructure and if this material is not the substrate material
#set VBO -0.1 ;# TEST
puts stderr "AlInP::VBO=$VBO"
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
initProperty $material BandStructure Bandgap Default
# initProperty $material BandStructure TableBGN Piprek

initProperty $material BandStructure eDOSMass Default
initProperty $material BandStructure hDOSMass Default

initProperty $material Mobility ConstantMobility Default
# initProperty $material Mobility DopingDependence Default

# initProperty $material Optics ComplexRefractiveIndex Schubert_MDF
initProperty $material Optics TableODB Breselge

initProperty $material Recombination Scharfetter Default
initProperty $material Recombination Auger Default_4CPV
initProperty $material Recombination RadiativeRecombination Default_4CPV

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print
${material}::Bandgap::print

${material}::eDOSMass::print
${material}::hDOSMass::print

${material}::ConstantMobility::print

# ${material}::ComplexRefractiveIndex::print
${material}::TableODB::print

${material}::Scharfetter::print
${material}::Auger::print
${material}::RadiativeRecombination::print
)!

SchroedingerParameters {
	Formula = 2
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
#	mt	= GaInP_mte_NLM ,	GaInP_mth_NLM	# [1]	
	mt	= 0.05 ,	0.14	# [1]	
	g = 0.21 , 0.4
}

ThermionicEmission {
        Formula=1
	A = 2, 2  # [1]
	B = 4, 4  # [1]
	C = 1, 1  # [1]
}


