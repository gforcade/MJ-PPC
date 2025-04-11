#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.6 2008/07/18 13:17:21 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: GaAs
#! PROPERTY: electron Density of States (DOS) and DOS mass
#! EXPRESSION: 
#! Room temperature electron DOS mass is used to calculate the DOS using
#! Nc = 2*(2*pi*mn*k*T/h^2)^(3/2)
#! CALCULATED PARAMETER:
#! mm returns mn/m0 [1]
#! VALIDITY: This model is valid at all temperatures under the assumption of temperature independent effective mass
#! NOTES:
#! Formula 1 is used to calculate the electron DOS
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2007/09/05 by Sameer Shah

namespace eval GaAs::eDOSMass {
    proc init {} {
# Room temperature parameters from Levinshtein
	set mn300 0.063
	
# Sdevice Parameters 	
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm $mn300
	variable Nc300
    	variable Nc

# Calculate electron DOS        
   	set Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]
    }
    proc print {} {printPar::eDOSMass1Section}    
}
GaAs::eDOSMass::init
