#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.3 2007/09/05 10:01:35 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: electron Density of States (DOS) and DOS mass 
#! EXPRESSION: 
#! Temperature dependent electron DOS is calculated using 
#! Nc(T) = Nc300 * (T/300)^3/2 
#! and temperature dependent electron DOS mass is calculated using
#! me/m0 = (Nc300/2.540e19)^2/3 
#! CALCULATED PARAMETER:
#! Nc300 returns room temperature electron DOS [cm^-3]
#! me/m0 returns electron DOS mass [1]
#! VALIDITY: 
#! NOTES:
#! Formula 2 is used to calculate the electron DOS 
#! SDEVICE:
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY: Created by Sameer Shah

namespace eval MQW_eff::eDOSMass {
    proc init {} {
# parameters from sdevice
	    variable Formula 2
	    variable Nc300 2.2e18

# calculate temperature dependent electron DOS
	    variable Nc
	    set Nc [expr {$Nc300*pow($::temp/300.0,3.0/2.0)}]

# calculate temperature dependent electron DOS mass
	    variable me
	    set me [expr {pow($Nc300/2.540e19, 2.0/3.0)}]
    }
    proc print {} {printPar::eDOSMass2Section}    
}
MQW_eff::eDOSMass::init
	
