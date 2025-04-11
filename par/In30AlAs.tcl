!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material InAlAs         ; # Specify material name
#set VBO [expr {0.4*(1.247*0.3+1.5*(1.0-$::xMole)-0.4*(1.0-$::xMole)*(1.0-$::xMole))}]
#puts stderr "InGaAsN::VBO=$VBO for mole fraction $::xMole"
#Ref: Levinshtein
    
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

initProperty $material BandStructure Bandgap Adachi

initProperty $material Mobility ConstantMobility Lumb
initProperty $material Mobility DopingDependence Lumb 

initProperty $material Recombination Auger Default
initProperty $material Recombination RadiativeRecombination MB
initProperty $material Recombination Scharfetter MB

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Bandgap::print

${material}::ConstantMobility::print
${material}::DopingDependence::print

${material}::Auger::print
${material}::RadiativeRecombination::print
${material}::Scharfetter::print

)!

ComplexRefractiveIndex
{ * Complex refractive index model: n_complex = n + i*k (unitless)
  * Base refractive index and extinction coefficient
    n_0 = 3 # [1]
    k_0 = 0.00 # [1]
}

Epsilon
{ *  Ratio of the permittivities of material and vacuum
  * epsilon() = epsilon
  # Valid on for In52AlAs.
  # Reference: Springer Handbook of Electronic and Photonic Materials 2nd edition (ch. 30 - Adachi)
  # Linear interpolation between InAs (14.3) and AlAs (10.06)
	epsilon	= 12.3
}

eDOSMass
{
Formula = 2
* me/m0 = (Nc300/2.540e19)^2/3
* Nc(T) = Nc300 * (T/300)^3/2
  # Valid on for In52AlAs.
  # Reference: Adachi - Properties of Semiconductor Alloys: Group-IV, III–V and II–VI Semiconductors, 2009
    Nc300	= 4.8e+17	# [cm-3]
}

* Reference: 
hDOSMass
{
Formula = 2
* mh/m0 = (Nv300/2.540e19)^2/3
* Nv(T) = Nv300 * (T/300)^3/2
  # Valid on for In52AlAs.
  # Reference: Ioffe & Adachi (HH for AlAs)
   	Nv300	= 1.2e+19	# [cm-3] #
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


