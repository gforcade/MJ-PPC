!(
#-------------------------------
# Variable Definition section
#-------------------------------
set material InGaAs         ; # Specify material name
#set VBO [expr {0.4*(1.247*0.3+1.5*(1.0-$::xMole)-0.4*(1.0-$::xMole)*(1.0-$::xMole))}]
#puts stderr "InGaAsN::VBO=$VBO for mole fraction $::xMole"
#Ref: Levinshtein

    
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

initProperty $material BandStructure Bandgap Piprek_rev
initProperty $material Mobility ConstantMobility Sotoodeh
#if {$::doping != 0} {
  initProperty $material Mobility DopingDependence Sotoodeh 
#}
initProperty $material Optics TableODB Bhattacharya 

initProperty $material Recombination Auger Default
initProperty $material Recombination RadiativeRecombination MW
initProperty $material Recombination Scharfetter MW-TDD

#---------------------------
# Parameter Printing section
#---------------------------
# print parameter sections in par file

${material}::Bandgap::print

${material}::ConstantMobility::print
${material}::DopingDependence::print

${material}::TableODB::print

${material}::Auger::print
${material}::RadiativeRecombination::print
${material}::Scharfetter::print

)!

ComplexRefractiveIndex
{ *  Complex refractive index model: n_complex = n + i*k (unitless)
  *  
  *  with n = n_0 + delta_n_lambda + delta_n_T + delta_n_carr + delta_n_gain 
  *       k = k_0 + delta_k_lambda             + delta_k_carr                
  
  * Base refractive index and extinction coefficient: 
  *    n_0, k_0 
	n_0	= 3.5108	# [1]
	k_0	= 0.0000e+00	# [1]
  
  * Wavelength dependence (real and imag): 
  *    Formula 0: delta_n_lambda = Cn_lambda * lambda + Dn_lambda * lambda^2 
  *               delta_k_lambda = Ck_lambda * lambda + Dk_lambda * lambda^2 
  *    Formula 1: Read tabulated values 
  *               NumericalTable (...)  
  *    Formula 2: Read tabulated values from file 
  *               NumericalTable = <string> 
  *    Formula 3: Read tabulated values from ODB Table 
       Formula = 3
	Cn_lambda	= 0.0000e+00	# [um^-1]
	Dn_lambda	= 0.0000e+00	# [um^-2]
	Ck_lambda	= 0.0000e+00	# [um^-1]
	Dk_lambda	= 0.0000e+00	# [um^-2]
        TableInterpolation = Linear
  * Temperature dependence (real): 
  *    delta_n_T = n_0 * ( Cn_temp * (T-Tpar)) 
	Cn_temp	= 4.0000e-04	# [K^-1]
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

Epsilon
{ *  Ratio of the permittivities of material and vacuum

  * epsilon() = epsilon
  * Mole fraction dependent model.
  * If only constant parameters are specified, those values will be
  * used for any mole fraction instead of the interpolation below.
  * Linear interpolation is used on the interval [0,1].
	epsilon(0)	= 14.55	# [1]
	epsilon(1)	= 13.18	# [1]
}

eDOSMass
{
  * For effective mass specificatition Formula1 (me approximation):
  * or Formula2 (Nc300) can be used :
	Formula	= 2	# [1]
  * Formula2:
  * me/m0 = (Nc300/2.540e19)^2/3 
  * Nc(T) = Nc300 * (T/300)^3/2 
  * Mole fraction dependent model.
  * If only constant parameters are specified, those values will be
  * used for any mole fraction instead of the interpolation below.
  * Linear interpolation is used on the interval [0,1].
	a(0)	= 0.1905	# [1]
	a(1)	= 0.1905	# [1]
	ml(0)	= 0.9163	# [1]
	ml(1)	= 0.9163	# [1]
	mm(0)	= 0.0000e+00	# [1]
	mm(1)	= 0.0000e+00	# [1]
	Nc300(0)	= 8.7200e+16	# [cm-3]
	Nc300(1)	= 4.4200e+17	# [cm-3]
}

hDOSMass
{
  * For effective mass specificatition Formula1 (mh approximation):
  * or Formula2 (Nv300) can be used :
	Formula	= 2	# [1]
  * Formula2:
  * mh/m0 = (Nv300/2.540e19)^2/3 
  * Nv(T) = Nv300 * (T/300)^3/2 
  * Mole fraction dependent model.
  * If only constant parameters are specified, those values will be
  * used for any mole fraction instead of the interpolation below.
  * Linear interpolation is used on the interval [0,1].
	a(0)	= 0.443587	# [1]
	a(1)	= 0.443587	# [1]
	b(0)	= 3.6095e-03	# [K^-1]
	b(1)	= 3.6095e-03	# [K^-1]
	c(0)	= 1.1735e-04	# [K^-2]
	c(1)	= 1.1735e-04	# [K^-2]
	d(0)	= 1.2632e-06	# [K^-3]
	d(1)	= 1.2632e-06	# [K^-3]
	e(0)	= 3.0256e-09	# [K^-4]
	e(1)	= 3.0256e-09	# [K^-4]
	f(0)	= 4.6834e-03	# [K^-1]
	f(1)	= 4.6834e-03	# [K^-1]
	g(0)	= 2.2869e-04	# [K^-2]
	g(1)	= 2.2869e-04	# [K^-2]
	h(0)	= 7.4693e-07	# [K^-3]
	h(1)	= 7.4693e-07	# [K^-3]
	i(0)	= 1.7275e-09	# [K^-4]
	i(1)	= 1.7275e-09	# [K^-4]
	mm(0)	= 0.0000e+00	# [1]
	mm(1)	= 0.0000e+00	# [1]
	Nv300(0)	= 6.6600e+18	# [cm-3]
	Nv300(1)	= 8.4700e+18	# [cm-3]
}

ThermionicEmission {
        Formula=1
	A = 2, 2  # [1]
	B = 4, 4  # [1]
	C = 1, 1  # [1]
}

