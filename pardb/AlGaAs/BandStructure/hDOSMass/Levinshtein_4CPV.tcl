#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.2 2008/07/15 13:53:37 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: AlGaAs
#! PROPERTY: hole Density of States (DOS) and DOS mass 
#! EXPRESSION:
#! Temperature dependent hole DOS is calculated using
#! Nv=4.82e15*T^(3/2)*(0.51+0.25*x)^(3/2)
#! and temperature dependent hole DOS mass is calculated using
#! mh/m0 = (h^2/(2*pi*kB*T*m0))*(Nv/2)^2
#! CALCULATED PARAMETER:
#! mm returns mh/m0 [1]
#! VALIDITY: 
#! NOTES:
#! Formula 1 is used to calculate the hole DOS 
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2007/09/06 by Sameer Shah

namespace eval AlGaAs::hDOSMass {
    proc init {} {
	variable Formula 1
    	variable a 0
	variable b 0
	variable c 0
	variable d 0
	variable e 0
	variable f 0
	variable g 0
	variable h 0
	variable i 0	
    	variable mm  
	variable Nv

	set Nv [expr {4.82e15*pow($::temp, 3.0/2.0)*pow(0.51+0.25*$::xMole,3.0/2.0)}]
	set mm [expr {(pow($Nv*1.0e6/2.0,2.0/3.0))*$::h*$::h/(2.0*$::pi*$::m0*$::kB*$::temp)}]	
    }
    proc print {} {printPar::hDOSMass1Section}    
}
AlGaAs::hDOSMass::init
