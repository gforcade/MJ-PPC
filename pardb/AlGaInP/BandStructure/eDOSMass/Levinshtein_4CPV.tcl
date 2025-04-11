#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/07/23 10:40:01 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: AlGaInP
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

namespace eval AlGaInP::eDOSMass {
    proc init {} {
# Parameters from sdevice           
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm

# Calculate electron DOS   
        if {$::xMole == 0.25} {
            variable Nc 1.06e18 ;# Cyrium value
        } else {
            puts stderr "AlGaInP/BandStructure/eDOSMass/Levinshtein_4CPV: Electron DOS mass is not defined for xMole not equal to 0.25"
            exit -1
        }
# Calculate electron DOS effective mass        
        set mn 0.1214 ;# Cyrium value
        set mm $mn
    }
    proc print {} {printPar::eDOSMass1Section}    
}
AlGaInP::eDOSMass::init
