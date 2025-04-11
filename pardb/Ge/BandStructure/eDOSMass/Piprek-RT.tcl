#----------------------------------------------------------------------#
# $Id: Piprek-RT.tcl,v 1.3 2008/07/17 14:28:42 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: model from Piprek
#! MATERIAL: Ge
#! PROPERTY: electron Density of States (DOS) and DOS mass
#! EXPRESSION: 
#! Room Temperature electron DOS mass is calculated using the room temperature L valley mass, mc
#! and the number of equivalent valleys in the conduction banc, M
#! me/m0 = mc*M^(2/3)
#! and the DOS is calculated using
#! Nc = 2*(2*pi*kB*T*me*m0/h^2)^(3/2)   
#! CALCULATED PARAMETER:
#! mm returns me/m0 [1]
#! VALIDITY: This model is valid near room temperature since room temperature me is used to calculate Nc
#! NOTES:
#! Formula 1 is used to calculate the room temperature electron DOS mass
#! SDEVICE:
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2007/09/06 by Sameer Shah

namespace eval Ge::eDOSMass {
    proc init {} {
# Room temperature parameters from Piprek (Table 1.1, page 7)	
	set mc 0.22                             ;# Effective mass of the DOS in one valley of conduction band
        set M 4

# Parameters from sdevice
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm [expr {pow($M,2.0/3.0)*$mc}]     ;# Conduction band DOS effective mass 
    	variable Nc
       
# Calculate electron DOS        
	set Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]
    }
    proc print {} {printPar::eDOSMass1Section}    
}
Ge::eDOSMass::init
