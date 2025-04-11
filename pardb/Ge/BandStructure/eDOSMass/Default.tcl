#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/09/05 13:41:29 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: Ge
#! PROPERTY: electron Density of States (DOS) and DOS mass 
#! EXPRESSION: 
#! Temperature dependent electron DOS is calculated using 
#! me/m0 = [ (6 * mt)^2 *  ml ]^(1/3) + mm
#! where, mt = a[Eg(0)/Eg(T)] 
#! and temperature dependent electron DOS mass is calculated using
#! Nc(T) = 2(2pi*kB/h_Planck^2*me*T)^3/2 = 2.540e19 ((me/m0)*(T/300))^3/2
#! CALCULATED PARAMETER:
#! mm returns me/m0 [1]
#! VALIDITY: 
#! NOTES:
#! Formula 1 is used to calculate the electron DOS 
#! SDEVICE: 
#! REFERENCE:
#! Sentaurus Device User Guide
#! HISTORY: Created by Sameer Shah
#! HISTORY:
#! Created on 2007/09/05 by Sameer Shah

namespace eval Ge::eDOSMass {
    proc init {} {
# parameters from sdevice        
	    variable Formula 1
    	variable a 0.0
	    variable ml 0.0
    	variable mm 0.55
# Calculate electron DOS        
	    variable Nc [expr {2.0*pow(2.0*$::pi*$::m0*$mm*$::kB*$::temp/($::h*$::h*1.0e4),3.0/2.0)}]			    		    	
    }
    proc print {} {printPar::eDOSMass1Section}    
}
Ge::eDOSMass::init
