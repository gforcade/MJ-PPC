#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.2 2007/09/06 10:15:04 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature and mole fraction dependent model from Levinshtein
#! MATERIAL: AlGaAs
#! PROPERTY: electron Density of States (DOS) and DOS mass 
#! EXPRESSION: 
#! Mole fraction dependent electron DOS mass is used to calculate DOS using expressions given in script below
#! CALCULATED PARAMETER:
#! mm returns me/m0 [1]
#! VALIDITY: 
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
	    variable Formula 1
    	variable a 0.0
	    variable ml 0.0
    	variable mm 
	    variable Nc

# Parameters from Levinshtein
        if {$::xMole < 0.41} {
            set m_gamma [expr {0.063+0.083*$::xMole}]
            set mm $m_gamma
        } elseif {$::xMole > 0.45} {
            set m_cd [expr {0.85-0.14*$::xMole}]
            set mm $m_cd
        } else {
            puts stderr "AlGaAs::BandStructure::eDOSMass::Levinshtein: Electron DOS mass is not defined for xMole=(0.41,0.45)"
            exit -1
        }
# Calculate DOS              
        set Nc [expr {4.82e15*pow($::temp*$mm,3.0/2.0)}]
    }
    proc print {} {printPar::eDOSMass1Section}    
}
AlGaAs::eDOSMass::init
