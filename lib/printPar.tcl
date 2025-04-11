
#-----------------------------------------------------------#
# $Id: printPar.tcl,v 1.12 2007/09/07 13:28:11 sameers Exp $
#-----------------------------------------------------------#

set tcl_precision 17
set CWD [pwd]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]


##source "$CWD/../lib/PhysicalConstants.tcl"

# Validate inputs 

#---------------------------------------------
# Input Validation for temp, xMole, yMole, cbo
#---------------------------------------------
if {![info exists temp]} {
    puts stderr "Please specify temperature in mpr command file"
    exit -1
} elseif {[info exists temp] && ($::temp < 0)} {
    puts stderr "Please enter a positive value for temperature"
    exit -1
}
if {[info exists cbo]} {
    if {$cbo > 1.0 || $cbo < 0.0} {
	    puts stderr "cbo=$cbo is out of range \[0,1\]!"
	    exit -1
    } 
}
if {[info exists xMole] && [string trim $::xMole]!=""} {
    if {$xMole < 0.0 || $xMole > 1.0} {
        puts stderr "x mole fraction is out of range \[0,1\]!"
        exit -1
    }
}
    


#------------------------------------------------------------------
# Procedures for printing header and parameter sections in par file
#------------------------------------------------------------------

namespace eval printPar {
    proc header {} {
	set pmaterial "--"
	set ptemp "--"
	set psubstrate "--"
	set pcbo "--"
	set pdoping "--"
	set pxMole "--"
	set pyMole "--"
	if {[info exists ::material] && [string trim $::material]!=""} {set pmaterial $::material}
	if {[info exists ::temp] && [string trim $::temp]!=""} {set ptemp $::temp}
	if {[info exists ::substrate] && [string trim $::substrate]!=""} {set psubstrate $::substrate}
	if {[info exists ::cbo] && [string trim $::cbo]!=""} {set pcbo $::cbo}
	if {[info exists ::doping] && [string trim $::doping]!=""} {set pdoping $::doping}
	if {[info exists ::xMole] && [string trim $::xMole]!=""} {set pxMole $::xMole}
	if {[info exists ::yMole] && [string trim $::yMole]!=""} {set pyMole $::yMole}
	print "
**************************************************
* Material parameter file for $pmaterial
* Temperature                 : $ptemp \[K\]
* Substrate                   : $psubstrate
* conduction band offset ratio: $pcbo \[1\]
* Doping concentration        : $pdoping \[cm-3\]
* Mole fraction x             : $pxMole \[1\]
* Mole fraction y             : $pyMole \[1\]
*************************************************\n\n
*************************************************
* Material Parameter sections
*************************************************\n\n"
    }
#-----------------------------------------------------------------------------------------------------------------------  
# Static dielectric permittivity

    proc EpsilonSection {} {
	if {![info exists ::plotter]} {
	    print "
* Static dielectric permittivity\n
Epsilon 
\{ 
  * Ratio of the permittivities of material and vacuum
  * epsilon() = epsilon
  * [format "epsilon(%.1f) = %.3f " $::temp [evalVar "${::material}::Epsilon::epsilon"]]
        epsilon = [format "%.4f" [evalVar "${::material}::Epsilon::epsilon"]]     # \[1\]
\}\n\n"
	}    
    }
#-----------------------------------------------------------------------------------------------------------------------  
    proc RefractiveIndexSection {} {
	if {![info exists ::plotter]} {
	    print "
RefractiveIndex
\{ 
  * Optical Refractive Index

  * refractiveindex() = refractiveindex * (1 + alpha * (T-Tpar))
  * [format "refractiveindex(%.1f) = %.5f " $::temp [evalVar "${::material}::RefractiveIndex::ri"]]

        Tpar    = [format "%6.4e    # \[K\]" [evalVar "${::material}::RefractiveIndex::Tpar"]]
        refractiveindex	= [format "%6.4f        # \[1\]" [evalVar "${::material}::RefractiveIndex::refractiveindex"]]
        alpha   = [format "%6.4e    # \[1/K\]" [evalVar "${::material}::RefractiveIndex::alpha"]]

  * Gain dependence of refractive index in active region:
  * a) Linear model: delta n = a0 * ( (n+p)/2 - N0 )
  * b) Logarithmic model: delta n = a0 * log ( (n+p)/(2 * N0) )
  * where n/p are the carrier densities in the active region. 
        a0      = [format "%6.4e    # \[cm^3 or 1\]" [evalVar "${::material}::RefractiveIndex::a0"]]
        N0      = [format "%6.4e    # \[1/cm^3 or 1\]" [evalVar "${::material}::RefractiveIndex::N0"]]
\}\n\n"
	}
    }

#-----------------------------------------------------------------------------------------------------------------------  
# Thermal Properties: Lattice Heat Capacity

    proc LatticeHeatCapacitySection {} {
        if {![info exists ::plotter]} {
	    print "
LatticeHeatCapacity
\{ 
  * lumped electron-hole-lattice heat capacity

  * cv() = cv + cv_b * T + cv_c * T^2 + cv_d * T^3 

  * [format "cv(%.1f) = %6.4e J/(K cm^3)" $::temp [evalVar "${::material}::LatticeHeatCapacity::cv_T"]]
        cv	= [format "%6.4f        # \[J/(K cm^3)\]" [evalVar "${::material}::LatticeHeatCapacity::cv"]]
        cv_b    = [format "%6.4e    # \[J/(K^2 cm^3)\]" [evalVar "${::material}::LatticeHeatCapacity::cv_b"]]
        cv_c    = [format "%6.4e    # \[J/(K^2 cm^3)\]" [evalVar "${::material}::LatticeHeatCapacity::cv_c"]]
        cv_d    = [format "%6.4e    # \[J/(K^2 cm^3)\]" [evalVar "${::material}::LatticeHeatCapacity::cv_d"]]
\}\n\n"
        }
    }

#-----------------------------------------------------------------------------------------------------------------------  
# Thermal Properties: Thermal Conductivity

    proc Kappa1Section {} {
        if {![info exists ::plotter]} {
	    print "
Kappa
\{ 
  * Lattice thermal conductivity

  * Formula = 1:
  * kappa() = kappa + kappa_b * T + kappa_c * T^2 
  * [format "kappa(%.1f) = %6.4e W/(K cm)" $::temp [evalVar "${::material}::Kappa::kappa_T"]]
        kappa	= [format "%6.4f        # \[W/(K cm)\]" [evalVar "${::material}::Kappa::kappa"]]
        kappa_b = [format "%6.4e    # \[W/(K^2 cm)\]" [evalVar "${::material}::Kappa::kappa_b"]]
        kappa_c = [format "%6.4e    # \[W/(K^2 cm)\]" [evalVar "${::material}::Kappa::kappa_c"]]
\}\n\n"
        }
    }

#-----------------------------------------------------------------------------------------------------------------------  
# Band gap, electron affinity

    proc BandgapSection {} {
	if {![info exists ::plotter]} {
	    print "
* Band gap, electron affinity\n
Bandgap
\{
  * Eg = Eg0 + alpha Tpar^2 / (beta + Tpar) - alpha T^2 / (beta + T)
  * Parameter 'Tpar' specifies the value of lattice 
  * temperature, at which parameters below are defined
  * Chi0 is electron affinity.
        Chi0	= [format "%.4f        # \[eV\]" [evalVar "${::material}::Bandgap::Chi0"]]
	    Bgn2Chi = [format "%.3f           # \[1\]" [evalVar "${::material}::Bandgap::Bgn2Chi"]]
        Eg0     = [format "%.4f        # \[eV\]" [evalVar "${::material}::Bandgap::Eg0"]]
        alpha   = [format "%6.4e    # \[eV K^(-1)\]" [evalVar "${::material}::Bandgap::alpha"]]
        beta	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::beta"]]
        Tpar	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::Tpar"]]
"
        if {[info exists ${::material}::Bandgap::Eg_override]} {
             print "** Eg_override  = [format "%.4f  # \[eV\]" [evalVar "${::material}::Bandgap::Eg_override"]]\n"
        }

print "\}\n\n"
	}
    }

#-----------------------------------------------------------------------------------------------------------------------  
# Band gap, electron affinity for dilute nitrides

    proc DNBandgapSection {} {
	if {![info exists ::plotter]} {
	    print "
* Band gap, for electron affinity - see DiluteNitride_Affinity\n
DiluteNitride_Bandgap
\{
  * Eg = 0.5*(( Egnn + En) - sqrt( (Egnn - En)^2 + 4*V^2*n))    
  * Egnn = Egnn0 + alpha Tpar^2 / (beta + Tpar) - alpha T^2 / (beta + T)
  * Parameter 'Tpar' specifies the value of lattice 
  * temperature, at which parameters below are defined
  * [format "Eg(%.1f) = %.5f eV" $::temp [evalVar "${::material}::Bandgap::Eg"]]
        Chi0	= [format "%.4f        # \[eV\]" [evalVar "${::material}::Bandgap::Chi0"]]
	Bgn2Chi = [format "%.1f           # \[1\]" [evalVar "${::material}::Bandgap::Bgn2Chi"]]
        Egnn0     = [format "%.4f        # \[eV\]" [evalVar "${::material}::Bandgap::Egnn0"]]
        alpha   = [format "%6.4e    # \[eV K^(-1)\]" [evalVar "${::material}::Bandgap::alpha"]]
        beta	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::beta"]]
        dn_En	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::dn_En"]]
        dn_V	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::dn_V"]]
        dn_n	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::dn_n"]]
        Tpar	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::Tpar"]]
 \}\n\n
* Electron affinity\n
DiluteNitride_Affinity
\{
  * Eg = 0.5*(( Egnn + En) - sqrt( (Egnn - En)^2 + 4*V^2*y))    
  * Egnn = Egnn0 + alpha Tpar^2 / (beta + Tpar) - alpha T^2 / (beta + T)
  * Parameter 'Tpar' specifies the value of lattice 
  * temperature, at which parameters below are defined
  * Chi0 is electron affinity.
  * [format "Chi(%.1f) = %.5f eV" $::temp [evalVar "${::material}::Bandgap::Chi"]]
  * [format "Eg(%.1f) = %.5f eV" $::temp [evalVar "${::material}::Bandgap::Eg"]]
        Chi0	= [format "%.4f        # \[eV\]" [evalVar "${::material}::Bandgap::Chi0"]]
	Bgn2Chi = [format "%.1f           # \[1\]" [evalVar "${::material}::Bandgap::Bgn2Chi"]]
        Egnn0     = [format "%.4f        # \[eV\]" [evalVar "${::material}::Bandgap::Egnn0"]]
        alpha   = [format "%6.4e    # \[eV K^(-1)\]" [evalVar "${::material}::Bandgap::alpha"]]
        beta	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::beta"]]
        dn_En	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::dn_En"]]
        dn_V	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::dn_V"]]
        Tpar	= [format "%6.4e    # \[K\]" [evalVar "${::material}::Bandgap::Tpar"]]
 \}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  
# Bandgap Narrowing
#------------------------------------------------------------------------------------------------------------------------  
# Bandgap Narrowing

    proc JainRoulstonSection {} {
	if {![info exists ::plotter]} {
	    print "
* Bandgap Narrowing\n
JainRoulston 
\{ 
  * deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
  * where i is n for n-type or p for p-type 
  * [format "deltaEg(%6.4e cm^-3) = %.2f meV" $::doping [expr 1000*[evalVar "${::material}::JainRoulston::deltaEg"]]]
  A_n     = [format "%6.4e    \# \[eV cm\]" [evalVar "${::material}::JainRoulston::A_n"]]
  A_p     = [format "%6.4e    \# \[eV cm\]" [evalVar "${::material}::JainRoulston::A_p"]]
  B_n     = [format "%6.4e    \# \[eV cm^(3/4)\]" [evalVar "${::material}::JainRoulston::B_n"]]
  B_p     = [format "%6.4e    \# \[eV cm^(3/4)\]" [evalVar "${::material}::JainRoulston::B_p"]]
  C_n     = [format "%6.4e    \# \[eV cm^(3/2)\]" [evalVar "${::material}::JainRoulston::C_n"]]
  C_p     = [format "%6.4e    \# \[eV cm^(3/2)\]" [evalVar "${::material}::JainRoulston::C_p"]]
  D_n     = [format "%6.4e    \# \[eV cm^(3/2)\]" [evalVar "${::material}::JainRoulston::D_n"]]
  D_p     = [format "%6.4e    \# \[eV cm^(3/2)\]" [evalVar "${::material}::JainRoulston::D_p"]]
\}\n\n" 
	}
    }
#------------------------------------------------------------------------------------------------------------------------  
    proc delAlamoSection {} {
	if {![info exists ::plotter]} {
          print "
* Bandgap Narrowing\n
delAlamo 
\{ 
  * deltaEg = dEg0 + Ebgn  ln(N/Nref)  
  * dEg0 is defined in BandGap section
  * [format "deltaEg(%6.4e cm^-3) = %.2f meV" $::doping [expr 1000*[evalVar "${::material}::delAlamo::deltaEg"]]]                
         Ebgn	    = [format "%6.4e    \# \[eV\]" [evalVar "${::material}::delAlamo::Eref"]]              
         Nref	    = [format "%6.4e    \# \[cm^(-3)\]" [evalVar "${::material}::delAlamo::Nref"]]
\}\n\n"
	}  
    }

#------------------------------------------------------------------------------------------------------------------------  	
    proc TableBGNSection {} {
	if {![info exists ::plotter]} {
	    print "
* Bandgap Narrowing\n
TableBGN 
\{ 
  * In the band-gap narrowing table, a list of concentrations  
  * and the bandgap narrowing for them can be specified.
  * The first possibility is to specify total concentrations (the sum
  * of acceptor and donor concentration) and the band gap narrowing,
  * and then the table entries have the form:
  *   Total       Nt, deltaEg   \# \[ cm-3, eV \]
  * The second possibility is to specify the band gap narrowing for
  * acceptors and donors separately (This must not be combined with
  * specification of total concentrations).  The bandgap narrowing
  * then will be the sum of both contributions; if no acceptor or donor
  * entry exists, the respective bandgap narrowing contribution is 0.
  * The entries take the form:
  *   Donor       Nd, deltaEg  \ # \[ cm-3, eV \]
  *   Acceptor    Na, deltaEg   \# \[ cm-3, eV \]
  * For each of the two possibilities, any number of table entries might
  * be given in any order.  For concentrations which are below (above)
  * the smallest (largest) concentration specified in the appropriate
  * table, the bandgap narrowing associated to the smallest (largest)
  * entry is assumed.  For concentration which fall in between table
  * entries, the bandgap narrowing is assumed to be linear in the
  * logarithm of the respective concentration and is interpolated
  * accordingly.\n"
        set length_n [llength [evalVar2 "\$${::material}::TableBGN::Nd"]];  
#??????????????????????????????????????????????????????????????????????????????#
# evalVar in the following for loop does not work.
	    if 0 {
	    for {set i 0} {$i < $length_n} {incr i} {
		print [format "  Donor     %6.4e,  %+6.4e   \#\[ cm-3, eV \]\n" [lindex [evalVar "${::material}::TableBGN::Nd"] $i] [lindex [evalVar "${::material}::TableBGN::deltaEg_n"] $i]]
	    }
	    }
	    for {set i 0} {$i < $length_n} {incr i} {
		print [format "  Donor     %6.4e,  %+6.4e   \#\[ cm-3, eV \]\n" [lindex [evalVar2 "\$${::material}::TableBGN::Nd"] $i] [lindex [evalVar2 "\$${::material}::TableBGN::deltaEg_n"] $i]]
	    }
	    set length_p [llength  [evalVar2 "\$${::material}::TableBGN::Na"]]; 
	    for {set i 0} {$i < $length_p} {incr i} {
		print [format "  Acceptor  %6.4e,  %+6.4e   \#\[ cm-3, eV \]\n" [lindex [evalVar2 "\$${::material}::TableBGN::Na"] $i] [lindex [evalVar2 "\$${::material}::TableBGN::deltaEg_p"] $i]]
	    }
   	    print "\}\n\n"     
	}
    }



#------------------------------------------------------------------------------------------------------------------------  	

    proc FreeCarrierAbsorptionSection {} {
	if {![info exists ::plotter]} {
	    print "
FreeCarrierAbsorption
\{
  * Coefficients for free carrier absorption:
  * fcaalpha_n for electrons,
  * fcaalpha_p for holes

  * FCA = (alpha_n * n + alpha_p * p) * Light Intensity
        fcaalpha_n      = [format "%6.4e    # \[cm^2\]" [evalVar "${::material}::FreeCarrierAbsorption::alpha_n"]]
        fcaalpha_p      = [format "%6.4e    # \[cm^2\]" [evalVar "${::material}::FreeCarrierAbsorption::alpha_p"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	
# electron DOS mass: Formula1

    proc eDOSMass1Section {} {
	if {![info exists ::plotter]} {
	    print "
* electron DOS mass\n
eDOSMass
\{
  * For effective mass specificatition Formula1 (me approximation):
  * or Formula2 (Nc300) can be used :
  * Formula1:
  * me/m0 = \[ (6 * mt)^2 *  ml \]^(1/3) + mm
  * mt = a\[Eg(0)/Eg(T)\] 
  * Nc(T) = 2(2pi*kB/h_Planck^2*me*T)^3/2 = 2.540e19 ((me/m0)*(T/300))^3/2 
  * [format "me/m0(%.1f) = %6.4f " $::temp [evalVar "${::material}::eDOSMass::mm"]]
  * [format "Nc(%.1f) = %6.4e cm^(-3)" $::temp [evalVar "${::material}::eDOSMass::Nc"]]
 	    Formula   = [format "%d             # \[1\]" [evalVar "${::material}::eDOSMass::Formula"]]
        a         = [format "%6.4e    # \[1\]" [evalVar "${::material}::eDOSMass::a"]]
        ml        = [format "%6.4e    # \[1\]" [evalVar "${::material}::eDOSMass::ml"]]
        mm        = [format "%6.4e    # \[1\]" [evalVar "${::material}::eDOSMass::mm"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	
# electron DOS mass: Formula2

    proc eDOSMass2Section {} {
	if {![info exists ::plotter]} {
	    print "
* electron DOS mass\n
eDOSMass   
\{
  * For effective mass specificatition Formula1 (me approximation):
  * or Formula2 (Nc300) can be used :
  * Formula2:
  * me/m0 = (Nc300/2.540e19)^2/3 
  * Nc(T) = Nc300 * (T/300)^3/2 
 	    Formula = [format "%d             # \[1\]" [evalVar "${::material}::eDOSMass::Formula"]]
        Nc300   = [format "%6.4e    # \[cm-3\]" [evalVar "${::material}::eDOSMass::Nc300"]]
\}\n\n"
	}
    }


#------------------------------------------------------------------------------------------------------------------------  	
# hole DOS mass: Formula1

    proc hDOSMass1Section {} {
	if {![info exists ::plotter]} {
	    print "
* hole DOS mass\n
hDOSMass
\{
  * For effective mass specificatition Formula1 (mh approximation):
  * or Formula2 (Nv300) can be used :
  * Formula1:
  * mh =  m0*{\[(a+bT+cT^2+dT^3+eT^4)/(1+fT+gT^2+hT^3+iT^4)\]^(2/3) + mm}
  * Nv(T) = 2(2pi*kB/h_Planck^2*mh*T)^3/2 = 2.540e19 ((mh/m0)*(T/300))^3/2 
	    Formula   = [format "%d             \# \[1\]" [evalVar "${::material}::hDOSMass::Formula"]]
        a         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::a"]]
        b         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::b"]]
        c         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::c"]]
        d         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::d"]]
        e         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::e"]]
        f         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::f"]]
        g         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::g"]]
        h         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::h"]]
        i         = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::i"]]
        mm        = [format "%6.4e    \# \[1\]" [evalVar "${::material}::hDOSMass::mm"]]
        Nv300     = [format "%6.4e    \# \[cm-3\]" [evalVar "${::material}::hDOSMass::Nv"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	
# hole DOS mass: Formula2

    proc hDOSMass2Section {} {
	if {![info exists ::plotter]} {
	    print "
* hole DOS mass\n
hDOSMass
\{
  * For effective mass specificatition Formula1 (mh approximation):
  * or Formula2 (Nv300) can be used :
  * Formula2:
  * mh/m0 = (Nv300/2.540e19)^2/3 
  * Nv(T) = Nv300 * (T/300)^3/2 
 	    Formula = [format "%d             # \[1\]" [evalVar "${::material}::hDOSMass::Formula"]]
        Nv300   = [format "%6.4e    # \[cm-3\]" [evalVar "${::material}::hDOSMass::Nv300"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	
    proc SchroedingerParametersSection {} {
	if {![info exists ::plotter]} {
	    print "	
SchroedingerParameters:
\{ 
  * For the hole masses for Schroedinger equation you can
  * use different formulas.
  * 0: use the isotropic density of states effective mass
  * 1: (for materials with Si-like hole band structure)
  *    m(k)/m0=1/(A+-sqrt(B+C*((xy)^2+(yz)^2+(zx)^2)))
  *    where k=(x,y,z) is unit normal vector in reziprocal
  *    space.  '+' for light hole band, '-' for heavy hole band
  * 2: Heavy hole mass mh and light hole mass ml are
  *    specified explicitly.
  *    Use me as electron mass for free-carrier effect in 
  *    the refractive index model.
  * For electron masses, the following formula options exist:
  * 0: use the isotropic density of states effective mass
  * 1: (for materials with Si-like hole band structure)
  *    use the a, ml, and mm parameters from eDOSMass.
  *    Typically, this leads to anisotropy.
  * formula<0 means no default model and no default parameters
  *   are available, so you have to provide values for
  *   'formula' and the respective parameters in order to use
  *   this parameter set.
    	formula = [format "%d ,   %d       \# \[1\]" [evalVar "${::material}::SchroedingerParameters::formula_n"] [evalVar "${::material}::SchroedingerParameters::formula_p"]]
  * Formula(hole) 2 parameters:
        ml      = [format "%5.3f \# \[1\]" [evalVar "${::material}::SchroedingerParameters::ml"]]
        mh      = [format "%5.3f \# \[1\]" [evalVar "${::material}::SchroedingerParameters::mh"]]
        me      = [format "%5.3f \# \[1\]" [evalVar "${::material}::SchroedingerParameters::me"]]
  * Lifting of degeneracy of bulk valleys. The value for
  * electrons is added to the band edge for the subband
  * ladder of lower degeneracy if positive, and subtracted
  * from the band edge for the ladder of higher degeneracy
  * if negative. (that is, the value of the band edge is
  * always increased).  For holes, the value is subtracted from
  * the band edge for the heavy hole band is positive,
  * add added tp that of the light hole band if
  * negative.  The signs are such that the shift always
  * moves the band edges 'outward', away from midgap.  The
  * gap itself is defined as the separation of the
  * unshifted band edges and remains unaffected.
    	offset  = [format "%6.4e ,  %6.4e      # \[eV\]" [evalVar "${::material}::SchroedingerParameters::offset_n"] [evalVar "${::material}::SchroedingerParameters::offset_p"]]
  * Alternative to the specification of formula, offset,
  * and masses, you can make an arbitrary number of ladder
  * specification, 'eLadder(mz, mxy, deg, dE) and hLadder(...)
  * Here, mz is the quantization mass, mxy an in-plane DOS mass,
  * deg the ladder degeneracy, and dE an shift of the band edge
  * for the ladder (non-negative; the shift is always outward,
  * away from midgap).  When present, we solve the Schroedinger
  * equation separately for each ladder

  * Temperatures in rescaling of the mxy for eLadder and hLadder
    	ShiftTemperature	= [format "%6.4e ,  %6.4e      # \[K\]" [evalVar "${::material}::SchroedingerParameters::ShiftTemperature_n"] [evalVar "${::material}::SchroedingerParameters::ShiftTemperature_p"]]
\}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  	
# Low field Mobility models: Constant mobility and  Doping dependent mobility

    proc ConstantMobilitySection {} {
	if {![info exists ::plotter]} {
	    print "
* Low field Mobility models: Constant mobility  and Doping dependent Mobility\n
ConstantMobility:
\{ 
  * mu_const = mumax (T/T0)^(-Exponent)
  * [format "mu_const_n(%.1f) = %6.4e cm^2/(Vs)" $::temp [evalVar "${::material}::ConstantMobility::mu_const_n"]]
  * [format "mu_const_p(%.1f) = %6.4e cm^2/(Vs)" $::temp [evalVar "${::material}::ConstantMobility::mu_const_p"]]
	mumax	        =  [format "%6.4e , %6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::ConstantMobility::mumax_n"] [evalVar "${::material}::ConstantMobility::mumax_p"]]
        Exponent	=  [format "%.2f       , %.2f           \# \[1\]" [evalVar "${::material}::ConstantMobility::Exponent_n"] [evalVar "${::material}::ConstantMobility::Exponent_p"]]
	mutunnel	=  [format "%.2f       , %.2f           \# \[cm^2/(Vs)\]" [evalVar "${::material}::ConstantMobility::mutunnel_n"] [evalVar "${::material}::ConstantMobility::mutunnel_p"]]
\}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  	
# Arora model

    proc DopingDependenceAroraSection {} {
	if {![info exists ::plotter]} {
	    print "
* Arora Doping Dependent Mobility model\n
DopingDependence:
\{
  * For doping dependent mobility model three formulas
  * can be used. Formula1 is based on Masetti et al. approximation.
  * Formula2 uses approximation, suggested by Arora.
 	formula	= [format "%d          , %d              \# \[1\]" [evalVar "${::material}::DopingDependence::formula"] [evalVar "${::material}::DopingDependence::formula"]]
  * If formula=2, model suggested by Arora is used:
  * mu_dop = muminA + mudA/(1.+(N/N00)^AA),
  * where muminA=Ar_mumin*(T/T0)^Ar_alm; mudA = Ar_mud*(T/T0)^Ar_ald
  * N is net doping
  * N00=Ar_N0*(T/T0)^Ar_alN; AA = Ar_a*(T/T0)^Ar_ala
  * [format "mu_dop_n(%.1f,%5.3e) = %6.4e cm^2/(Vs)" $::temp $::doping [evalVar "${::material}::DopingDependence::mu_dop_n"]]
  * [format "mu_dop_p(%.1f,%5.3e) = %6.4e cm^2/(Vs)" $::temp $::doping [evalVar "${::material}::DopingDependence::mu_dop_p"]]
        Ar_mumin    = [format "%+6.4e , %+6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::Ar_mumin_n"] [evalVar "${::material}::DopingDependence::Ar_mumin_p"]]
	Ar_alm      = [format "%+6.4e , %+6.4e     \# \[1\]" [evalVar "${::material}::DopingDependence::Ar_alm_n"] [evalVar "${::material}::DopingDependence::Ar_alm_p"]]
	Ar_mud      = [format "%+6.4e , %+6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::Ar_mud_n"] [evalVar "${::material}::DopingDependence::Ar_mud_p"]]
	Ar_ald      = [format "%+6.4e , %+6.4e     \# \[1\]" [evalVar "${::material}::DopingDependence::Ar_ald_n"] [evalVar "${::material}::DopingDependence::Ar_ald_p"]]
	Ar_N0       = [format "%+6.4e , %+6.4e     \# \[cm^(-3)\]" [evalVar "${::material}::DopingDependence::Ar_N0_n"] [evalVar "${::material}::DopingDependence::Ar_N0_p"]]
	Ar_alN      = [format "%+6.4e , %+6.4e     \# \[1\]" [evalVar "${::material}::DopingDependence::Ar_alN_n"] [evalVar "${::material}::DopingDependence::Ar_alN_p"]]
	Ar_a        = [format "%+6.4e , %+6.4e     \# \[1\]" [evalVar "${::material}::DopingDependence::Ar_a_n"] [evalVar "${::material}::DopingDependence::Ar_a_p"]]
	Ar_ala      = [format "%+6.4e , %+6.4e     \# \[1\]" [evalVar "${::material}::DopingDependence::Ar_ala_n"] [evalVar "${::material}::DopingDependence::Ar_ala_p"]]
\}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  	
# Masetti model

    proc DopingDependenceMasettiSection {} {
	if {![info exists ::plotter]} {
	    print "
* Masetti Doping Dependent Mobility model\n
DopingDependence: 
\{
  * For doping dependent mobility model three formulas
  * can be used. Formula1 is based on Masetti et al. approximation.
  * Formula2 uses approximation, suggested by Arora.
 	formula	= [format "%d          , %d              \# \[1\]" [evalVar "${::material}::DopingDependence::formula"] [evalVar "${::material}::DopingDependence::formula"]]
  * If formula=1, model suggested by Masetti et al. is used:
  * mu_dop = mumin1 exp(-Pc/N) + (mu_const - mumin2)/(1+(N/Cr)^alpha)
  *                             - mu1/(1+(Cs/N)^beta)
  * with mu_const from ConstantMobility
  * [format "mu_const_n(%.1f) = %6.4e cm^2/(Vs)" $::temp [evalVar "${::material}::DopingDependence::mu_const_n"]]
  * [format "mu_dop_n(%.1f,%5.3e) = %6.4e cm^2/(Vs)" $::temp $::doping [evalVar "${::material}::DopingDependence::mu_dop_n"]]
  * [format "mu_const_p(%.1f) = %6.4e cm^2/(Vs)" $::temp [evalVar "${::material}::DopingDependence::mu_const_p"]]
  * [format "mu_dop_p(%.1f,%5.3e) = %6.4e cm^2/(Vs)" $::temp $::doping [evalVar "${::material}::DopingDependence::mu_dop_p"]]
    	mumin1	= [format "%6.4e , %6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::mumin1_n"] [evalVar "${::material}::DopingDependence::mumin1_p"]]
    	mumin2	= [format "%6.4e , %6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::mumin2_n"] [evalVar "${::material}::DopingDependence::mumin2_p"]]
    	mu1	= [format "%6.4e , %6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::mu1_n"] [evalVar "${::material}::DopingDependence::mu1_p"]]
    	Pc	= [format "%6.4e , %6.4e     \# \[cm^3\]" [evalVar "${::material}::DopingDependence::Pc_n"] [evalVar "${::material}::DopingDependence::Pc_p"]]
    	Cr	= [format "%6.4e , %6.4e     \# \[cm^3\]" [evalVar "${::material}::DopingDependence::Cr_n"] [evalVar "${::material}::DopingDependence::Cr_p"]]
    	Cs	= [format "%6.4e , %6.4e     \# \[cm^3\]" [evalVar "${::material}::DopingDependence::Cs_n"] [evalVar "${::material}::DopingDependence::Cs_p"]]
    	alpha	= [format "%6.4e , %6.4e     \# \[1\]" [evalVar "${::material}::DopingDependence::alpha_n"] [evalVar "${::material}::DopingDependence::alpha_p"]]
    	beta	= [format "%6.4e , %6.4e     \# \[1\]" [evalVar "${::material}::DopingDependence::beta_n"] [evalVar "${::material}::DopingDependence::beta_p"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	
# Sotoodeh model

    proc DopingDependenceSotoodehSection {} {
	if {![info exists ::plotter]} {
	    print "
* Sotoodeh Doping Dependent Mobility model\n
DopingDependence: 
\{
  * mu_dop = mumin1 + (mumax*(300/T)^theta1 - mumin) / (1 + (N/(nref*(T/300)^theta2))^lambda)
  * mummax corresponds to mu_const
  * [format "mu_max_n(%.1f) = %6.4e cm^2/(Vs)" $::temp [evalVar "${::material}::DopingDependence::mumax_n"]]
  * [format "mu_dop_n(%.1f,%5.3e) = %6.4e cm^2/(Vs)" $::temp $::doping [evalVar "${::material}::DopingDependence::mu_dop_n"]]
  * [format "mu_max_p(%.1f) = %6.4e cm^2/(Vs)" $::temp [evalVar "${::material}::DopingDependence::mumax_p"]]
  * [format "mu_dop_p(%.1f,%5.3e) = %6.4e cm^2/(Vs)" $::temp $::doping [evalVar "${::material}::DopingDependence::mu_dop_p"]]
    	So_mumax	= [format "%6.4e , %6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::mumax_n"] [evalVar "${::material}::DopingDependence::mumax_p"]]
    	So_mumin	= [format "%6.4e , %6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::mumin_n"] [evalVar "${::material}::DopingDependence::mumin_p"]]
    	So_nref	= [format "%6.4e , %6.4e     \# \[cm^2/(Vs)\]" [evalVar "${::material}::DopingDependence::nref_n"] [evalVar "${::material}::DopingDependence::nref_p"]]
    	So_theta1	= [format "%6.4e , %6.4e     \# \[cm^3\]" [evalVar "${::material}::DopingDependence::theta1_n"] [evalVar "${::material}::DopingDependence::theta1_p"]]
    	So_theta2	= [format "%6.4e , %6.4e     \# \[cm^3\]" [evalVar "${::material}::DopingDependence::theta2_n"] [evalVar "${::material}::DopingDependence::theta2_p"]]
    	So_lambda	= [format "%6.4e , %6.4e     \# \[cm^3\]" [evalVar "${::material}::DopingDependence::lambda_n"] [evalVar "${::material}::DopingDependence::lambda_p"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	
# High field Mobility model
# This procedure prints HighFieldDependence section with Transferred electron model  parameters and model 2 parameters for velocity saturation model

    proc HighFieldDependenceTEM2Section {} {
	if {![info exists ::plotter]} {
	    print "
* High field Mobility model\n
HighFieldDependence:
\{ 
  * Caughey-Thomas model:
  * mu_highfield = ( (alpha+1)*mu_lowfield ) / 
  *        ( alpha + ( 1 + ( (alpha+1)*mu_lowfield*E/vsat)^beta )^(1/beta) ) 
  * beta = beta0 (T/T0)^betaexp.
    	beta0	= [format "%d ,   %d       \# \[1\]" [evalVar "${::material}::HighFieldDependence::beta0_n"] [evalVar "${::material}::HighFieldDependence::beta0_p"]]
    	betaexp	= [format "%6.4e , %6.4e       \# \[1\]" [evalVar "${::material}::HighFieldDependence::betaexp_n"] [evalVar "${::material}::HighFieldDependence::betaexp_p"]]
    	alpha	= [format "%6.4e , %6.4e       \# \[1\]" [evalVar "${::material}::HighFieldDependence::alpha_n"] [evalVar "${::material}::HighFieldDependence::alpha_p"]]

  * Smoothing parameter for HydroHighField Caughey-Thomas model:
  * if Tl < Tc < (1+K_dT)*Tl, then smoothing between low field mobility
  * and HydroHighField mobility is used.
    	K_dT	= [format "%2.1f , %2.1f     \# \[1\]" [evalVar "${::material}::HighFieldDependence::K_dT_n"] [evalVar "${::material}::HighFieldDependence::K_dT_p"]]
  * Transferred-Electron Effect:
  * mu_highfield = (mu_lowfield+(vsat/E)*(E/E0_TrEf)^4)/(1+(E/E0_TrEf)^4)
    	E0_TrEf	= [format "%6.4e , %6.4e       \# \[1\]" [evalVar "${::material}::HighFieldDependence::E0_TrEf_n"] [evalVar "${::material}::HighFieldDependence::E0_TrEf_p"]]
    	Ksmooth_TrEf	= [format "%2d , %2d               \# \[1\]" [evalVar "${::material}::HighFieldDependence::Ksmooth_TrEf_n"] [evalVar "${::material}::HighFieldDependence::Ksmooth_TrEf_p"]]

 * For vsat either Formula1 or Formula2 can be used.
    	Vsat_Formula	= [format "%d ,   %d       \# \[1\]" [evalVar "${::material}::HighFieldDependence::Vsat_Formula_n"] [evalVar "${::material}::HighFieldDependence::Vsat_Formula_p"]]

 * Formula2 for saturation velocity:
 *            vsat = A_vsat - B_vsat*(T/T0)
 * (Parameter Vsat_Formula has to be equal to 2)
   	A_vsat	= [format "%6.4e , %6.4e       \# \[1\]" [evalVar "${::material}::HighFieldDependence::A_vsat_n"] [evalVar "${::material}::HighFieldDependence::A_vsat_p"]]
    	B_vsat	= [format "%6.4e , %6.4e       \# \[1\]" [evalVar "${::material}::HighFieldDependence::B_vsat_n"] [evalVar "${::material}::HighFieldDependence::B_vsat_p"]]
    	vsat_min= [format "%6.4e , %6.4e       \# \[1\]" [evalVar "${::material}::HighFieldDependence::vsat_min_n"] [evalVar "${::material}::HighFieldDependence::vsat_min_p"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	
# Absorption

        proc TableODBSection {} {
	if {![info exists ::plotter]} {
	    print "
* Absorption model\n
TableODB
\{ 
  * Each entry of the table consists of three values:
  * complex refractive index n + i*k (unitless) 
  * refractive index = n,  absorption coefficient = 4*pi*k/wavelength 
  *  WAVELEN(um)        n	       k\n"
	    set length [llength  [evalVar2 "\$${::material}::TableODB::llist"]]; 
	    for {set i 0} {$i < $length} {incr i} {
		print [format "   %9.7e  %9.7e  %9.7e;\n" [lindex [evalVar2 "\$${::material}::TableODB::llist"] $i] [lindex [evalVar2 "\$${::material}::TableODB::nlist"] $i] [lindex [evalVar2 "\$${::material}::TableODB::klist"] $i]]
	    }
	    print "\}\n\n"     
	}
    }
#------------------------------------------------------------------------------------------------------------------------  

# ComplexRefractiveIndex

        proc ComplexRefractiveIndexSection {} {
	if {![info exists ::plotter]} {
	    print "
* Complex Refractive Index model
ComplexRefractiveIndex
\{
* Complex refractive index model: n_complex = n + i*k (unitless)
* Base refractive index and extinction coefficient\n"
print "* n_0 = 3.45 # \[1\]\n"
print "* k_0 = 0.00 # \[1\]\n"
if { [info exists ${::material}::ComplexRefractiveIndex::TableInterpolation] } { 
   print "TableInterpolation = "
   print [evalVar2 "\$${::material}::ComplexRefractiveIndex::TableInterpolation"]
   print "\n" }

if { [evalVar2 "\$${::material}::ComplexRefractiveIndex::Formula"] == 1} {
  print "Formula = 1
  NumericalTable\(
  * Each entry of the table consists of three values:
  * complex refractive index n + i*k (unitless)
  * refractive index = n,  absorption coefficient = 4*pi*k/wavelength
  *  WAVELEN(um)        n	       k\n"
	    set length [llength  [evalVar2 "\$${::material}::ComplexRefractiveIndex::llist"]]; 
            puts $length
	    for {set i 0} {$i < $length} {incr i} {
		print [format "   %9.7e  %9.7e  %9.7e;\n" [lindex [evalVar2 "\$${::material}::ComplexRefractiveIndex::llist"] $i] [lindex [evalVar2 "\$${::material}::ComplexRefractiveIndex::nlist"] $i] [lindex [evalVar2 "\$${::material}::ComplexRefractiveIndex::klist"] $i]]
	    }
	    print "\)\n\n"
	    print "\}\n\n"     
	} 
      
     }
    }
#------------------------------------------------------------------------------------------------------------------------  
	
# Recombination Parameters: SRH, Radiative, Auger

    proc RadiativeRecombinationSection {} {
	if {![info exists ::plotter]} {
	    print "
* Recombination Parameters: SRH, Radiative, Auger\n
RadiativeRecombination * coefficients:
\{ 
  * R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)
  * C    
  * alpha 
	C	= [format "%6.4e    \# \[cm^3/s\]" [evalVar "${::material}::RadiativeRecombination::C"]]
	alpha	= [format "%6.4e    \# \[\]" [evalVar "${::material}::RadiativeRecombination::alpha"]]
\}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  	

    proc ScharfetterSection {} {
	if {![info exists ::plotter]} {
	    print "
Scharfetter * relation and trap level for SRH recombination:
\{ 
  * tau = taumin + ( taumax - taumin ) / ( 1 + ( N/Nref )^gamma)
  * tau(T) = tau * ( (T/300)^Talpha )          (TempDep)
  * tau(T) = tau * exp( Tcoeff * ((T/300)-1) ) (ExpTempDep)
	taumin	= [format "%6.4e , %6.4e     \# \[s\]" [evalVar "${::material}::Scharfetter::taumin_n"] [evalVar "${::material}::Scharfetter::taumin_p"]]
	taumax	= [format "%6.4e , %6.4e     \# \[s\]" [evalVar "${::material}::Scharfetter::taumax_n"] [evalVar "${::material}::Scharfetter::taumax_p"]]
	Nref	= [format "%6.4e , %6.4e     \# \[cm^(-3)\]" [evalVar "${::material}::Scharfetter::Nref_n"] [evalVar "${::material}::Scharfetter::Nref_p"]]
	gamma	= [format "%.1f        , %.1f            \# \[1\]" [evalVar "${::material}::Scharfetter::gamma_n"] [evalVar "${::material}::Scharfetter::gamma_p"]]
	Talpha	= [format "%6.4e , %6.4e     \# \[1\]" [evalVar "${::material}::Scharfetter::Talpha_n"] [evalVar "${::material}::Scharfetter::Talpha_p"]]
	Tcoeff	= [format "%6.4e , %6.4e     \# \[1\]" [evalVar "${::material}::Scharfetter::Tcoeff_n"] [evalVar "${::material}::Scharfetter::Tcoeff_p"]]
	Etrap	= [format "%6.4e                  \# \[eV\]" [evalVar "${::material}::Scharfetter::Etrap"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	

    proc AugerSection {} {
	if {![info exists ::plotter]} {
	    print "
Auger * coefficients:
\{ 
  * R_Auger = ( C_n n + C_p p ) ( n p - ni_eff^2)
  * with C_n,p = (A + B (T/T0) + C (T/T0)^2) (1 + H exp(-{n,p}/N0))
       A	= [format "%6.4e , %6.4e     \# \[cm^6/s\]" [evalVar "${::material}::Auger::A_n"] [evalVar "${::material}::Auger::A_p"]]
       B	= [format "%6.4e , %6.4e     \# \[cm^6/s\]" [evalVar "${::material}::Auger::B_n"] [evalVar "${::material}::Auger::B_p"]]
       C	= [format "%6.4e , %6.4e     \# \[cm^6/s\]" [evalVar "${::material}::Auger::C_n"] [evalVar "${::material}::Auger::C_p"]]
       H	= [format "%6.4e , %6.4e     \# \[1\]" [evalVar "${::material}::Auger::H_n"] [evalVar "${::material}::Auger::H_p"]]
       N0	= [format "%6.4e , %6.4e     \# \[cm^(-3)\]" [evalVar "${::material}::Auger::N0_n"] [evalVar "${::material}::Auger::N0_p"]]
\}\n\n"
	}
    }

#------------------------------------------------------------------------------------------------------------------------  	

    proc PooleFrenkelSection {} {
	if {![info exists ::plotter]} {
	    print "
PooleFrenkel
\{ 
  * TrapXsection = Xsec0*(1+Gpf) 
  * Gpf = (1+(a-1)*exp(a))/a^2-0.5 
  * where 
  *       a = (1/kT)*(q^3*F/pi/e0/epsPF)^0.5, 
  *       F is the electric field. 
        epsPF	= [format "%6.4f , %6.4f     \# \[1\]" [evalVar "${::material}::PooleFrenkel::epsPF_n"] [evalVar "${::material}::PooleFrenkel::epsPF_p"]]

\}\n\n"
	}
    }


#------------------------------------------------------------------------------------------------------------------------  	
# Parameters for non-local tunneling model

    proc BarrierTunnelingSection {} {
	if {![info exists ::plotter]} {
	    print "
*  Parameters for non-local tunneling model\n
BarrierTunneling  
\{ 
  * Non Local Barrier Tunneling 
  * G(r) = g*A*T/kB*F(r)*Pt(r)*ln\[(1+exp((E(r)-Es)/kB/T))/(1+exp((E(r)-Em)/kB/T))\]
  * where: 
  *     Pt(r) is WKB approximation for the tunneling probability 
  *     g = As/A, As is the Richardson constant for carriers in semiconductor
  *     A is the Richardson constant for free electrons 
  *     F(r) is the electric field 
  *     E(r) is carrier energy 
  *     Es is carrier quasi fermi energy in semiconductor
  *     Em is carrier fermi energy in metal 
  *     alpha is the prefactor for quantum potential correction 
        g       = [format "%.3f , %.3f               \# \[1\]" [evalVar "${::material}::BarrierTunneling::gc"] [evalVar "${::material}::BarrierTunneling::gv"]]
        mt      = [format "%6.4e , %6.4e     \# \[1\]" [evalVar "${::material}::BarrierTunneling::mc"] [evalVar "${::material}::BarrierTunneling::mv"]]
        alpha   = [format "%6.4e , %6.4e     \# \[1\]" [evalVar "${::material}::BarrierTunneling::alphac"] [evalVar "${::material}::BarrierTunneling::alphav"]]
\}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  	
# Parameters for band-to-band tunneling model

    proc Band2BandTunnelingSection {} {
	if {![info exists ::plotter]} {
	    print "
*  Parameters for band2band non-local tunneling model\n
Band2BandTunneling  
\{ 
  * Non Local Barrier Tunneling 
  * G(r) = g*A*T/kB*F(r)*Pt(r)*ln\[(1+exp((E(r)-Es)/kB/T))/(1+exp((E(r)-Em)/kB/T))\]
  * where: 
  *     Pt(r) is WKB approximation for the tunneling probability 
  *     g = As/A, As is the Richardson constant for carriers in semiconductor
  *     A is the Richardson constant for free electrons 
  *     F(r) is the electric field 
  *     E(r) is carrier energy 
  *     Es is carrier quasi fermi energy in semiconductor
  *     Em is carrier fermi energy in metal 
  *     alpha is the prefactor for quantum potential correction 
        m_c       = [format "%6.4e               \# \[m0\]" [evalVar "${::material}::Band2BandTunneling::mc"]]
        m_v      = [format "%6.4e     \# \[m0\]" [evalVar "${::material}::Band2BandTunneling::mv"]]
        degeneracy   = [format "%.3f     \# \[1\]" [evalVar "${::material}::Band2BandTunneling::g"]]
        Cpath      = [format "%6.4e     \# \[J^2cm kg-1\]" [evalVar "${::material}::Band2BandTunneling::Cp"]]
        Ppath   = [format "%6.4e     \# \[eV\]" [evalVar "${::material}::Band2BandTunneling::Pp"]]
        maxTunnelLength      = [format "%6.4e     \# \[cm\]" [evalVar "${::material}::Band2BandTunneling::mtl"]]
\}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  
# Parameters for Trap assisted tunneling model

    proc TrapAssistedTunnelingSection {} {
	if {![info exists ::plotter]} {
	    print "
*  Parameters for Trap assisted tunneling model\n
TrapAssistedTunneling  
\{ 
  * Schenk trap-assisted tunneling model 
  * shortens the SRH lifetime with electric field strength
  * 1/\[1 + g(F)\] = ...
  * where: 
  *     S is the huang rhys factor 
  *     hbarOmega is the effective phonon energy 
  *     m_theta is the electron and hole tunneling masses
  *	MinField is the minimum field needed to include the enhacnement
        S	= [format "%.3f		 \# \[1\]" [evalVar "${::material}::TrapAssistedTunneling::S"]]
	hbarOmega = [format "%0.3e               \# \[eV\]" [evalVar "${::material}::TrapAssistedTunneling::hbarOmega"]]
	MinField = [format "%6.4e               \# \[V cm-1\]" [evalVar "${::material}::TrapAssistedTunneling::MinField"]]
	m_theta       = [format "%6.4e , %6.4e     \# \[m0\]" [evalVar "${::material}::TrapAssistedTunneling::mc"] [evalVar "${::material}::TrapAssistedTunneling::mv"]]
\}\n\n"
	}
    }
#------------------------------------------------------------------------------------------------------------------------  

} ;# End of procedure printPar
