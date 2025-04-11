#! MODEL: room temperature model from Levinshtein
#! MATERIAL: Ge
#! PROPERTY: hole Density of States mass and Density of States
#! EXPRESSION: 
#! Room Temperature hole DOS mass is calculated using the light hole and heavy hole mass
#! mh/m0 = ((mlh)^(3/2)+(mhh)^(3/2))^(2/3)
#! CALCULATED PARAMETER:
#! mm returns mh/m0 [1]
#! NOTES:
#! Formula 1 is used to calculate the hole DOS mass
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2007/09/06 by Sameer Shah

namespace eval Ge::hDOSMass {
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
	variable Nv300 
	variable Nv
	
	variable mm  
	set mlh [expr double(0.043)]
	set mhh [expr double(0.33)]
	set num [expr {double(3.0/2.0)}]
	set numInv [expr {double(1.0/$num)}]
	set mm [expr {double(pow((pow($mlh,$num) + pow($mhh, $num)), $numInv))}]		    		    
	variable Nv300
	set Nv300 [expr {double(2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0))}]
	set Nv $Nv300
    }
    proc print {} {printPar::hDOSMass1Section}  
}
Ge::hDOSMass::init
