#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/09/07 14:01:38 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Model from sdevice
#! MATERIAL: Ge
#! PROPERTY: hole Density of States  (DOS) and DOS mass
#! EXPRESSION: hole DOS mass and DOS are calculated using
#! mh =  m0*{[(a+bT+cT^2+dT^3+eT^4)/(1+fT+gT^2+hT^3+iT^4)]^(2/3) + mm}
#! Nv(T) = 2(2pi*kB/h_Planck^2*mh*T)^3/2 = 2.540e19 ((mh/m0)*(T/300))^3/2 
#! CALCULATED PARAMETER:
#! mm and Nv
#! VALIDITY: 
#! NOTES:
#! Formula 1 is used to calculate the hole DOS mass
#! SDEVICE:
#! REFERENCE: 
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created on 2007/09/07 by Sameer Shah

namespace eval Ge::hDOSMass {
    proc init {} {
# Parameters from sdevice        
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
	    variable mm 0.382        
        
        variable Nv [expr {2.540933e19*pow($mm, 3.0/2.0)*pow($::temp/300.0, 3.0/2.0)}]
    }
    proc print {} {printPar::hDOSMass1Section}    
}
Ge::hDOSMass::init
