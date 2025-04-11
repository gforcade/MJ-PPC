#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.2 2008/07/17 13:09:13 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Piprek
#! MATERIAL: InP
#! PROPERTY: hole Density of States  (DOS) and DOS mass
#! EXPRESSION: 
#! Room Temperature hole DOS mass is calculated using the light hole and heavy hole mass
#! mh/m0 = ((mlh)^(3/2)+(mhh)^(3/2))^(2/3)
#! and the DOS is calculated using
#! Nv = 2*(2*pi*kB*T*mh*m0/h^2)^(3/2)  
#! CALCULATED PARAMETER:
#! mm returns mh/m0 [1]
#! VALIDITY: This model is valid at all temperatures under the assumption of temperature independent effective mass
#! NOTES:
#! Formula 1 is used to calculate the room temperature hole DOS mass
#! SDEVICE:
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2008/07/16 by Sameer Shah

namespace eval InP::hDOSMass {
    proc init {} {
# Room temperature parameters from Piprek (Table 2.2, page 21)
	set mhh 0.56
        set mlh 0.12	
	
# Parameters from sdevice        
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
        
# Calculate hole DOS mass and DOS        
	set num [expr {3.0/2.0}]
	set numInv [expr {1.0/$num}]
        set mm [expr {pow((pow($mlh,$num) + pow($mhh, $num)), $numInv)}]
        set Nv [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]
    }
    proc print {} {printPar::hDOSMass1Section}    
}
InP::hDOSMass::init
