#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.3 2007/09/05 10:01:35 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Levinshtein
#! MATERIAL: GaAs
#! PROPERTY: electron Density of States (DOS) and DOS mass 
#! EXPRESSION: 
#! Temperature dependent electron DOS is calculated using 
#! Nc=8.63e13*T^(3/2)*[1-1.93e-4*$T-4.19e-8*$T*$T+21*exp(-$Egl*$q/($kB*$T))+44*exp(-$Egx*$q/($kB*$T))]
#! and temperature dependent electron DOS mass is calculated using
#! me/m0 = (h^2/(2*pi*kB*T*m0))*(Nc/2)^2
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
#! Created by Sameer Shah

namespace eval GaAs::eDOSMass {
    proc init {} {
	    variable Formula 1
    	variable a 0.0
	    variable ml 0.0
    	variable mm 
	    variable Nc
			    		    
    	set Eg [expr {1.519-5.405e-4*$::temp*$::temp/($::temp+204)}]
	    set El [expr {1.815-6.050e-4*$::temp*$::temp/($::temp+204)}]
    	set Ex [expr {1.981-4.600e-4*$::temp*$::temp/($::temp+204)}]
	    set Egl [expr {$El-$Eg}]
    	set Egx [expr {$Ex-$Eg}]
	    set Nc [expr  {8.63e13*(pow($::temp,3.0/2.0))*(1-1.93e-4*$::temp-4.19e-8*$::temp*$::temp+21*exp(-$Egl*$::q/($::kB*$::temp))+44*exp(-$Egx*$::q/($::kB*$::temp)))}]
    	set mm [expr {(pow($Nc*1.0e6/2.0,2.0/3.0))*$::h*$::h/(2.0*$::pi*$::m0*$::kB*$::temp)}]	
    }
    proc print {} {printPar::eDOSMass1Section}    
}
GaAs::eDOSMass::init
