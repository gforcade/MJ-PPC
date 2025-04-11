#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.3 2008/07/07 14:23:52 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: hole Density of States (DOS) mass 
#! EXPRESSION: 
#! Temperature dependent hole DOS is calculated using 
#! Nv(T) = Nv300 * (T/300)^3/2 
#! and temperature dependent hole DOS mass is calculated using
#! me/m0 = (Nv300/2.540e19)^2/3 
#! CALCULATED PARAMETER:
#! Nc300 returns room temperature hole DOS [cm^-3]
#! me/m0 returns hole DOS mass [1]
#! VALIDITY: 
#! NOTES:
#! SDEVICE:
#! Formula 2 is used to calculate the hole DOS 
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2007/08/10 by Sameer Shah
#! 2008/07/07:	Corrected the Expression in the header section

namespace eval GaAs::hDOSMass {
    proc init {} {
# parameters from sdevice
	variable Formula 2
	variable Nv300 8.47e18

# calculate temperature dependent hole DOS
	variable Nv
	set Nv [expr {$Nv300*pow($::temp/300.0,3.0/2.0)}]

# calculate temperature dependent hole DOS mass
	variable mh
	set mh [expr {pow($Nv300/2.540e19, 2.0/3.0)}]
    }
    proc print {} {printPar::hDOSMass2Section}    
}
GaAs::hDOSMass::init
	
