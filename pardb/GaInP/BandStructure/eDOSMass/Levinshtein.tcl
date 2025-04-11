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
	variable Formula 2

        variable Nc300 6.55e17
}
    proc print {} {printPar::eDOSMass2Section}    
}
GaInP::eDOSMass::init
