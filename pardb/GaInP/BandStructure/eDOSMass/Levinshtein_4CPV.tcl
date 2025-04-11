#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/07/23 10:40:01 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: GaInP
#! PROPERTY: electron Density of States (DOS) and DOS effective mass
#! EXPRESSION:
#! Temperature dependent electron DOS is used to calculate the electron DOS mass using
#! mn/m0 = (Nc/2)^(2/3) * (h^2/2*pi*kB*T*mn*m0)
#! CALCULATED PARAMETER:
#! mm returns mn/m0 [1]
#! VALIDITY: 
#! NOTES:
#! Formula 1 is used to calculate the electron DOS and DOS mass. 
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2008/07/23 by Sameer Shah

namespace eval GaInP::eDOSMass {
    proc init {} {
# Parameters from sdevice           
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm

# Calculate electron DOS   
        if {$::xMole <= 0.63} {
            variable Nc [expr {1.2e14*pow($::temp,3.0/2.0)}]
        } elseif {$::xMole >= 0.78} {
            variable Nc [expr {4.82e15*pow($::temp,3.0/2.0)*(0.66+0.13*$::xMole)}]
        } else {
            puts stderr "GaInP/BandStructure/eDOSMass/Levinshtein: Electron DOS mass is not defined for xMole=(0.63,0.78)"
            exit -1
        }
# Calculate electron DOS effective mass        
        set mn [expr {pow($Nc/2.0, 2.0/3.0)*($::h*$::h*1.0e4/(2*$::pi*$::kB*$::temp*$::m0))}]
        set mm $mn
    }
    proc print {} {printPar::eDOSMass1Section}    
}
GaInP::eDOSMass::init
