#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2008/07/16 11:31:43 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Piprek
#! MATERIAL: AlGaInP
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
#! Created on 2008/07/15 by Sameer Shah

namespace eval AlGaInP::hDOSMass {
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

        set mm 0.6244
        set Nv 1.24e19 ;# Cyrium values for 4CPV
    }
    proc print {} {printPar::hDOSMass1Section}    
}
AlGaInP::hDOSMass::init
