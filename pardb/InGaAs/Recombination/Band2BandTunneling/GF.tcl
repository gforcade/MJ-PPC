#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2019/08/13 M Beattie $ 
#----------------------------------------------------------------------#
#! MODEL: Band 2 Band tunneling model parameters from sdevice
#! MATERIAL: InGaAs
#! PROPERTY: Band 2 band tunneling
#! EXPRESSION: 
#! #! CALCULATED PARAMETER: 
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Band2Band(Schenk)
#! REFERENCE: 
#! HISTORY:
#! Created on 2022/12/13 by Gavin Forcade - SUNLAB

namespace eval InGaAs::Band2BandTunneling {
    proc init {} {
	# effective masses of electrons and holes.

	#mlh = 1/ (gamma1 + (2*gamma2^2 + 2*gamma3^2)^1/2)
	set mlh_GaAs [expr {1.0 / (6.98 + pow(2.0 *pow(2.06,2) + 2.0*pow(2.93,2),0.5))}] 
	set mlh_InAs [expr {1.0 / (20.0 + pow(2.0 *pow(8.5,2) + 2.0*pow(9.2,2),0.5))}] 
	variable mv [expr {[::compute_ternary $::xMole $mlh_InAs $mlh_GaAs 0.0202]}]

	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	variable mc [expr pow($Nc/2.54e19,2.0/3.0)]


	# degeneracy of tunneling (4 as we have 2 x 2 bands for tunneling)
	    variable g 4.0
	# phonon assisted tunneling, only useful for Si. Keep Pp=0.0.
	    variable Cp 8.3e-11
	    variable Pp 0.0
	# max tunnel length
	    variable mtl 100e-7   



    }
    proc print {} {printPar::Band2BandTunnelingSection}    
}
InGaAs::Band2BandTunneling::init
