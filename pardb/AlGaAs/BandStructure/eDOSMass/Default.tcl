#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/09/05 13:41:29 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and molde fraction dependent model from sdevice
#! MATERIAL: AlGaAs
#! PROPERTY: electron Density of States (DOS) and DOS mass 
#! EXPRESSION: 
#! Temperature dependent electron DOS is calculated using 
#! Nc(x,T) = Nc300(x) * (T/300)^3/2 
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

namespace eval AlGaAs::eDOSMass {
    proc init {} {
# parameters from sdevice
	    variable Formula 2
	    variable Nc300 [expr {4.42e+17 + (6.68e+17)*$::xMole}]

# calculate temperature dependent electron DOS
	    variable Nc
	    set Nc [expr {$Nc300*pow($::temp/300.0,3.0/2.0)}]

# calculate temperature dependent electron DOS mass
	    variable me
	    set me [expr {pow($Nc300/2.540e19, 2.0/3.0)}]
    }
    proc print {} {printPar::eDOSMass2Section}    
}
AlGaAs::eDOSMass::init
	
