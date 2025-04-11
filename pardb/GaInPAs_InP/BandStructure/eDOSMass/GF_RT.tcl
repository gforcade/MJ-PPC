#----------------------------------------------------------------------#
# $Id: MB.tcl,v 1.1 2021/11/17 G Forcade $
#----------------------------------------------------------------------#
#! MODEL: Interpolation with bowing,    xMole is ___InP__ mole fraction!!!
#! MATERIAL: GaInPAs_InP
#! PROPERTY: electron Density of States (DOS) and DOS mass
#! EXPRESSION: 
#! Room Temperature electron DOS mass is given by the room temperature Gamma valley mass
#! me/m0
#! and the DOS is calculated using
#! Nc = 2*(2*pi*kB*T*me*m0/h^2)^(3/2)   
#! CALCULATED PARAMETER:
#! mm returns me/m0 [1]
#! VALIDITY: This model is valid near room temperature since room temperature me is used to calculate Nc
#! NOTES:
#! Formula 1 is used to calculate the room temperature electron DOS mass
#! SDEVICE:
#! REFERENCE: 
#! Adachi III-V ternary and quaternary semiconductor properties 2009
#! HISTORY:
#! Created on 2021/11/17 by Gavin Forcade - uOttawa SUNLAB

namespace eval GaInPAs_InP::eDOSMass {
    proc init {} {
# Room temperature parameters 
	set mc [expr {0.04084 + 0.03384*$::xMole + 0.00459*$::xMole*$::xMole}]

# Parameters from sdevice
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm 
    	variable Nc

# Calculate electron DOS mass	
        set mm $mc

# Calculate DOS        
	set Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]
    }
    proc print {} {printPar::eDOSMass1Section}    
}
GaInPAs_InP::eDOSMass::init
