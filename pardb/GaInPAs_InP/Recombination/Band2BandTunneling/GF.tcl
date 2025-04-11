#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2019/08/13 M Beattie $ 
#----------------------------------------------------------------------#
#! MODEL: Band 2 Band tunneling model parameters from sdevice. ____InP___ is xMole fraction !!!
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

namespace eval GaInPAs_InP::Band2BandTunneling {
    proc init {} {
	# effective masses of electrons and light holes.
	    variable mc
	    variable mv [expr {0.0528 + 0.0386*$::xMole + 0.0302*$::xMole*$::xMole}]


	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	set mc [expr pow($Nc/2.54e19,2.0/3.0)]


	# degeneracy of tunneling (4 as we have 2 x 2 bands for tunneling)
	    variable g 4.0
	# phonon assisted tunneling, only useful for Si. Keep Pp=0.0.
	    variable Cp 8.3e-11
	    variable Pp 0.0
	# max tunnel length (cm)
	    variable mtl 100e-7   



    }
    proc print {} {printPar::Band2BandTunnelingSection}    
}
GaInPAs_InP::Band2BandTunneling::init
