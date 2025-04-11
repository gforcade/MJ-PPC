!(
#----------------------------
# Variable Definition section
#----------------------------
set material AlGaAs         ; # Specify material name
set VBO [expr {-$::xMole*0.46}]
puts stderr "AlGaAs::VBO=$VBO"

#---------------------------------------------
# Input Validation and Header Printing section
#---------------------------------------------
# Validate variables and print header section in par file

source ../lib/printPar.tcl
printPar::header

#---------------------------------
# Parameter Initialization section
#---------------------------------
# Initialize parameters

initProperty $material Permittivity Epsilon Piprek_4CPV 
initProperty $material BandStructure Bandgap Default_4CPV
initProperty $material BandStructure TableBGN Levinshtein

initProperty $material BandStructure eDOSMass Levinshtein_4CPV
initProperty $material BandStructure hDOSMass Levinshtein_4CPV
initProperty $material Mobility ConstantMobility Sotoodeh
initProperty $material Mobility DopingDependence Sotoodeh_4CPV
initProperty $material Optics TableODB djurisic

initProperty $material Recombination RadiativeRecombination Levinshtein_4CPV
initProperty $material Recombination Scharfetter Default_4CPV
initProperty $material Recombination Auger Default_4CPV

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Epsilon::print

${material}::Bandgap::print
${material}::TableBGN::print

${material}::eDOSMass::print
${material}::hDOSMass::print
${material}::TableODB::print

${material}::ConstantMobility::print
${material}::DopingDependence::print
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
        g	= 0.42 ,	0.8
}

ComplexRefractiveIndex
{ *  Complex refractive index model: n_complex = n + i*k (unitless)
  *  
  *  with n = n_0 + delta_n_lambda + delta_n_T + delta_n_carr + delta_n_gain 
  *       k = k_0 + delta_k_lambda             + delta_k_carr                
  
  * Base refractive index and extinction coefficient: 
  *    n_0, k_0 
	n_0	= 3.33	# [1]
	k_0	= 0.0000e+00	# [1]
  
  * Wavelength dependence (real and imag): 
  *    Formula 0: delta_n_lambda = Cn_lambda * lambda + Dn_lambda * lambda^2 
  *               delta_k_lambda = Ck_lambda * lambda + Dk_lambda * lambda^2 
  *    Formula 1: Read tabulated values 
  *               NumericalTable (...)  
  *    Formula 2: Read tabulated values from file 
  *               NumericalTable = <string> 
  *    Formula 3: Read tabulated values from ODB Table 
	TableInterpolation = Linear
       Formula = 3
	Cn_lambda	= 0.0000e+00	# [um^-1]
	Dn_lambda	= 0.0000e+00	# [um^-2]
	Ck_lambda	= 0.0000e+00	# [um^-1]
	Dk_lambda	= 0.0000e+00	# [um^-2]
  
  * Temperature dependence (real): 
  *    delta_n_T = n_0 * ( Cn_temp * (T-Tpar)) 
	Cn_temp	= 2.0000e-04	# [K^-1]
	Tpar	= 3.0000e+02	# [K]
  
  * Carrier dependence (real) 
  *    delta_n_carr = - Cn_carr * (const.) * (n/m_e + p/m_h) 
	Cn_carr	= 1	# [1]
  
  * Carrier dependence (imag) 
  *    delta_k_carr = wavelength / (4*PI) * (Ck_carr_n*n + Ck_carr_p*p) 
	Ck_carr	= 0.0000e+00 ,	0.0000e+00	# [cm^2]
  
  * Gain dependence (real) 
  *    lin: delta_n_gain = Cn_gain * ( (n+p)/2 - Npar ) 
  *    log: delta_n_gain = Cn_gain * log ( (n+p)/(2 - Npar ) )
	Cn_gain	= 0.0000e+00	# [cm^3]
	Npar	= 1.0000e+18	# [cm^-3]
} 
