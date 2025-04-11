#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/07/23 11:15:26 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Piprek
#! MATERIAL: AlInP
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
#! Gergoe's Material Parameter Database
#! HISTORY:
#! Created on 2008/07/23 by Sameer Shah

namespace eval AlInP::hDOSMass {
    proc init {} {
# Calculate hole DOS         
    variable Formula 2
    variable Nv300 1e19
    }
    proc print {} {printPar::hDOSMass2Section}    
}
AlInP::hDOSMass::init
