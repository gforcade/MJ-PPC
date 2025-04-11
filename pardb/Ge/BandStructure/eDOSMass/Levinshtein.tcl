#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2007/09/06 05:00:44 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: Ge
#! PROPERTY: electron Density of States (DOS) and DOS mass 
#! EXPRESSION: 
#! Conduction band DOS mass is used to calculate DOS using expressions given in script below
#! CALCULATED PARAMETER:
#! mm returns me/m0 [1]
#! VALIDITY: 
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
	    variable Formula 1
    	variable a 0.0
	    variable ml 0.0
    	variable mm 
	    variable Nc

# Parameters from Levinshtein
        set mll 1.59
        set mt 0.0815
        set M 4
        set mc [expr {pow($mll*$mt*$mt, 1.0/3.0)}]  ;# Effective mass of the DOS in one valley of conduction band
        set mcd [expr {pow($M,2.0/3.0)*$mc}]        ;# Conduction band DOS effective mass 
# Calculate DOS  
        set mm $mcd
        set Nc [expr {4.82e15*pow($mcd*$::temp, 3.0/2.0)}]
    }
    proc print {} {printPar::eDOSMass1Section}    
}
Ge::eDOSMass::init
