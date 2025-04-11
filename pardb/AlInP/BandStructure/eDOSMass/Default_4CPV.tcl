#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.2 2008/07/23 11:14:41 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: AlInP
#! PROPERTY: electron Density of States (DOS) and DOS effective mass
#! EXPRESSION:
#! The electron DOS effective mass is used to calcualate the electron DOS using
#! Nc = 2*(2*pi*kB*T*mn*m0/h^2)^(3/2)   
#! CALCULATED PARAMETER:
#! mm returns mn/m0 [1]
#! VALIDITY: This model is valid only for x=0.5
#! NOTES:
#! Electron DOS effective mass is used to calculate temperature dependent electron DOS.
#! Formula 1 is used to calculate the electron DOS and DOS mass. 
#! SDEVICE:
#! REFERENCE: 
#! Gergoe's Material Parameter Database
#! HISTORY:
#! Created on 2008/07/23 by Sameer Shah

namespace eval AlInP::eDOSMass {
    proc init {} {
# Parameters from Reference
	set mn 0.23
	
# Parameters from sdevice           
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm 
        
# Calculate electron DOS mass	
        set mm $mn
        
# Calculate electron DOS        
	variable Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]        
    }
    proc print {} {printPar::eDOSMass1Section}    
}
AlInP::eDOSMass::init
