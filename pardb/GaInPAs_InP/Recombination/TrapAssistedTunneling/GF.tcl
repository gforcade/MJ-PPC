#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2019/08/13 M Beattie $ 
#----------------------------------------------------------------------#
#! MODEL: Trap assisted tunneling model parameters from sdevice. ____InP___ is xMole fraction !!!
#! MATERIAL: InGaAsP
#! PROPERTY: Trap assisted tunneling
#! EXPRESSION: 
#! #! CALCULATED PARAMETER: 
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: TrapAssisted tunneling Schenk model.
#! REFERENCE: 
#! HISTORY:
#! Created on 2022/12/13 by Gavin Forcade - SUNLAB

namespace eval GaInPAs_InP::TrapAssistedTunneling {
    proc init {} {
	# effective masses of electrons and light holes.
	variable mc
	variable mv [expr {0.0528 + 0.0386*$::xMole + 0.0302*$::xMole*$::xMole}]


	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	set mc [expr pow($Nc/2.54e19,2.0/3.0)]


	# effective phonon energy in [eV]. Using values from Piprek 2003.
	variable hbarOmega 
	set hbarOmega [expr {0.033*(1.0 - $::xMole) + 0.043*$::xMole}] 


	#Huang-Rhys factor. Unitless
	variable S $::S

	#minimum field to inlcude this enhancement. in [V/cm]
	variable MinField 1.0e3



    }
    proc print {} {printPar::TrapAssistedTunnelingSection}    
}
GaInPAs_InP::TrapAssistedTunneling::init
