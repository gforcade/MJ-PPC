#----------------------------------------------------------------------#
# $Id: MB.tcl,v 1.1 2019/08/15 M Beattie $
#----------------------------------------------------------------------#
#! MODEL: Linear interpolation
#! MATERIAL: InAlGaAs_InP
#! PROPERTY: hole Density of States (DOS) and DOS mass
#! EXPRESSION: 
#! Room Temperature electron DOS mass is given by the room temperature Gamma valley mass
#! mh/m0
#! and the DOS is calculated using
#! Nv = 2*(2*pi*kB*T*mh*m0/h^2)^(3/2)   
#! CALCULATED PARAMETER:
#! mm returns mh/m0 [1]
#! VALIDITY: This model is valid near room temperature since room temperature me is used to calculate Nv
#! NOTES:
#! Formula 1 is used to calculate the room temperature hole DOS mass
#! SDEVICE:
#! REFERENCE: 
#! Ioffe MaterialDB & Adachi III-V ternary and quaternary semiconductor properties 2009
#! HISTORY:
#! Created on 2019/08/15 by Meghan Beattie - uOttawa SUNLAB

namespace eval InAlGaAs_InP::hDOSMass {
    proc init {} {
# Room temperature parameters from Piprek (Table 1.1, page 7)
	set mv [expr {0.607*$::xMole + 0.45*(1-$::xMole)}]

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

# Calculate electron DOS mass	
        set mm $mv

# Calculate DOS        
	set Nv [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]
    }
    proc print {} {printPar::hDOSMass1Section}    
}
InAlGaAs_InP::hDOSMass::init
