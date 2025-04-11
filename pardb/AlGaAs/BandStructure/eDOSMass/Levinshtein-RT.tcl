#----------------------------------------------------------------------#
# $Id: Levinshtein-RT.tcl,v 1.3 2008/07/18 13:17:21 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Mole fraction and temperature dependent model from Levinshtein
#! MATERIAL: AlGaAs
#! PROPERTY: electron Density of States (DOS) and DOS mass
#! EXPRESSION: 
#! Mole fraction dependent room temperature electron DOS mass is used to calculate the DOS using
#! Nc = 2*(2*pi*mn*k*T/h^2)^(3/2)
#! CALCULATED PARAMETER:
#! mm returns mn/m0 [1]
#! VALIDITY: This model is valid under the assumption of temperature independent effective mass
#! NOTES:
#! Formula 1 is used to calculate the electron DOS
#! SDEVICE:
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2007/09/05 by Sameer Shah

namespace eval AlGaAs::eDOSMass {
    proc init {} {
# Room temperature parameters from Levinshtein        
        if {$::xMole < 0.41} {
            set mn300 [expr {0.063+0.083*$::xMole}]
        } elseif {$::xMole > 0.45} {
            set mn300 [expr {0.85-0.14*$::xMole}]
        } else {
            puts stderr "$AlGaAs::BandStructure::eDOSMass::Levinshtein-RT: me300 is not defined for 0.41< xMole <0.45"
            exit -1
        }

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
AlGaAs::eDOSMass::init
