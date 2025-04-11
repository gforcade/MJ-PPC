#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2019/08/13 M Beattie $ 
#----------------------------------------------------------------------#
#! MODEL: Barrier tunneling model parameters from sdevice. ____InP___ is xMole fraction !!!
#! MATERIAL: InGaAsP
#! PROPERTY: Band 2 band tunneling, interband and intraband
#! EXPRESSION: 
#! #! CALCULATED PARAMETER: 
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Barrier Tunneling
#!  * Non Local Barrier Tunneling 
#!  * G(r) = g*A*T/kB*F(r)*Pt(r)*ln\[(1+exp((E(r)-Es)/kB/T))/(1+exp((E(r)-Em)/kB/T))\]
#! REFERENCE: 
#! HISTORY:
#! Created on 2022/12/13 by Gavin Forcade - SUNLAB

namespace eval GaInPAs_InP::BarrierTunneling {
    proc init {} {
	# effective masses of electrons and light holes.
	variable mc
	variable mv [expr {0.0528 + 0.0386*$::xMole + 0.0302*$::xMole*$::xMole}]


	# get eDOSMass from file
	set Nc [evalVar "${::material}::eDOSMass::Nc"]
	set mc [expr pow($Nc/2.54e19,2.0/3.0)]


	# degeneracy of tunneling 
	variable gc 2.0
	variable gv 2.0

	# alpha is the prefactor for quantum potential correction
	variable alphac 0.0
	variable alphav 0.0
   



    }
    proc print {} {printPar::BarrierTunnelingSection}    
}
GaInPAs_InP::BarrierTunneling::init
