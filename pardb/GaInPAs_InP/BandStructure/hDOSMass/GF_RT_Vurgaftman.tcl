#----------------------------------------------------------------------#
# $Id: MB.tcl,v 1.1 2021/11/17 G Forcade $
#----------------------------------------------------------------------#
#! MODEL: Linear interpolation,    xMole is ___InP__ mole fraction!!!

#! MATERIAL: GaInAsP_InP
#! PROPERTY: hole Density of States (DOS) and DOS mass
#! EXPRESSION: 
#! Room Temperature electron DOS mass is given by the room temperature Gamma valley mass
#! mh/m0
#! and the DOS is calculated using
#! Nv = 2*(2*pi*kB*T*mh*m0/h^2)^(3/2)   
#! CALCULATED PARAMETER:
#! mm returns mh/m0 [1]
#! VALIDITY: This model is valid near room temperature since room temperature mh is used to calculate Nv
#! NOTES:
#! Formula 1 is used to calculate the room temperature hole DOS mass
#! SDEVICE:
#! REFERENCE: 
#! mlh, Vurgaftman "Band parameters for III-V compound semiconductors and their alloys" 2001
#! HISTORY:
#! Created on 2021/11/17 by Gavin Forcade - uOttawa SUNLAB

namespace eval GaInPAs_InP::hDOSMass {
    proc init {} {
#gamma variables from Vurgaftman. Linearly interpolating between GaInAs and InP boundaries
	set gamma1 [expr {11.01*(1.0 - $::xMole) + 5.08*$::xMole}]
	set gamma2 [expr {4.18*(1.0 - $::xMole) + 1.6*$::xMole}]
	set gamma3 [expr {4.84*(1.0 - $::xMole) + 2.1*$::xMole}]
	

#  Equations from Adachi 2017.
	set gamma_bar [expr {pow(2.0*$gamma2*$gamma2 + 2.0*$gamma3*$gamma3,1.0/2.0)}]
	set gamma_h [expr {6.0*($gamma3*$gamma3 - $gamma2*$gamma2)/($gamma_bar*($gamma1 - $gamma_bar))}]
	set mhh [expr {pow(1.0 + 0.05*$gamma_h + 0.0164*$gamma_h*$gamma_h,2.0/3.0)/($gamma1 - $gamma_bar)}]

#from Vurgaftman. InP_x
	set mlh [expr {0.052 + 0.0386*$::xMole + 0.0302*$::xMole*$::xMole}]
	set mv [expr {pow(pow($mlh,3.0/2.0) + pow($mhh,3.0/2.0),2.0/3.0)}]

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
GaInPAs_InP::hDOSMass::init
