#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2019/08/13 M Beattie $ 
#----------------------------------------------------------------------#
#! MODEL: Barrier tunneling model parameters from sdevice. ____In___ is xMole fraction !!!
#! MATERIAL: InGaAs
#! PROPERTY: Band 2 band tunneling, interband and intraband
#! EXPRESSION: 
#! #! CALCULATED PARAMETER: 
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Barrier Tunneling
#!  * Non Local Barrier Tunneling 
#!  * G(r) = g*A*T/kB*F(r)*Pt(r)*ln\[(1+exp((E(r)-Es)/kB/T))/(1+exp((E(r)-Em)/kB/T))\]
#! REFERENCE: light hole, using Vurgaftmann
#! HISTORY:
#! Created on 2022/12/13 by Gavin Forcade - SUNLAB

namespace eval InGaAs::BarrierTunneling {
    proc init {} {
	#mlh = 1/ (gamma1 + (2*gamma2^2 + 2*gamma3^2)^1/2)
	set mlh_GaAs [expr {1.0 / (6.98 + pow(2.0 *pow(2.06,2) + 2.0*pow(2.93,2),0.5))}] 
	set mlh_InAs [expr {1.0 / (20.0 + pow(2.0 *pow(8.5,2) + 2.0*pow(9.2,2),0.5))}] 

	# effective masses of electrons and light holes.
	variable mc
	variable mv [expr {[::compute_ternary $::xMole $mlh_InAs $mlh_GaAs 0.0202]}]


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
InGaAs::BarrierTunneling::init
