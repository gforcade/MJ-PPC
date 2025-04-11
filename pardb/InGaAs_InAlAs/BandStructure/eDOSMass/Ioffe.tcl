#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.1 2008/07/23 10:40:01 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from ioffe
#! MATERIAL: InP
#! PROPERTY: electron Density of States (DOS) and DOS effective mass
#! EXPRESSION:
#! For conduction band with spherical isoenergy surface, electron DOS effective mass is given by
#! mn/m0 = me
#! For conduction band with ellipsoidal isoenergy surfaces, electron DOS effective mass is given by
#! mn/m0 = M^(2/3)*(mll*mt^2)^(1/3)
#! where mll = longitudinal effective mass, mt = transversal effective mass
#! and M = Number of equivalent conduction band minima
#! The electron DOS is calculated using
#! Nc = 2*(2*pi*kB*T*mn*m0/h^2)^(3/2)   
#! CALCULATED PARAMETER:
#! mm returns mn/m0 [1]
#! VALIDITY: This model is valid at all temperatures assuming temperature independent DOS effective mass
#! NOTES:
#! Room temperature electron DOS effective mass is used to calculate temperature dependent electron DOS.
#! The electron DOS effective mass and DOS are calculated for the conduction band (Gamma, X or L) corresponding to the semiconductor bandgap.
#! Formula 1 is used to calculate the electron DOS and DOS mass. 
#! SDEVICE:
#! REFERENCE: 
#! Ioffe
#! HISTORY:
#! Created on 2022/03/29 by Gavin Forcade

namespace eval InGaAs_InAlAs::eDOSMass {
    proc init {} {
# Room temperature parameters from Ioffe
	set mn 0.040887
	
# Parameters from sdevice           
	variable Formula 1
    	variable a 0.0
	variable ml 0.0
    	variable mm 
        
# Calculate electron DOS mass	
        set mm $mn
        
# Calculate electron DOS        
	variable Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]        
    }
    proc print {} {printPar::eDOSMass1Section}    
}
InGaAs_InAlAs::eDOSMass::init
