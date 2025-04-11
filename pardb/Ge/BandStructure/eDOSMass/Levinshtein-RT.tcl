#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.2 2008/07/18 13:17:22 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: Ge
#! PROPERTY: electron Density of States (DOS) and DOS mass
#! EXPRESSION: 
#! Room temperature electron DOS mass is used to calculate the DOS using
#! Nc = 2*(2*pi*mn*k*T/h^2)^(3/2)
#! CALCULATED PARAMETER:
#! mm returns mn/m0 [1]
#! VALIDITY: This model is valid under the assumption of temperature independent effective mass
#! NOTES:
#! Formula 1 is used to calculate the electron DOS
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2007/09/05 by Sameer Shah

namespace eval Ge::eDOSMass {
    proc init {} {
# Room temperature parameters from Levinshtein
	set mll 1.6
        set mt 0.08
        set M 4.0;	# number of equivalent valleys in the conduction band
        
# Sdevice Parameters	
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm
	variable Nc300
    	variable Nc

# Calculate electron DOS mass
	set mn300 [expr {(pow($M, 2.0/3.0))*(pow($mll*$mt*$mt,1.0/3.0))}]
        set mm $mn300 
        
# Calculate electron DOS        
   	    set Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]
    }
    proc print {} {printPar::eDOSMass1Section}    
}
Ge::eDOSMass::init
