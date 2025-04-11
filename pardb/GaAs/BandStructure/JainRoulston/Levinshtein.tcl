#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.7 2008/07/15 05:54:27 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999

namespace eval GaAs::JainRoulston {
    proc init {} {
# Parameters from Levinshtein		
        variable A_n [expr 16.3*pow(1e-18,1./3)*1e-3]           ;# [eV cm]
        variable A_p [expr 9.71*pow(1e-18,1./3)*1e-3]           ;# [eV cm]
        variable B_n [expr 7.47*pow(1e-18,1./4)*1e-3]         	;# [eV cm^(3/4)]
        variable B_p [expr 12.19*pow(1e-18,1./4)*1e-3]         	;# [eV cm^(3/4)]
        variable C_n [expr 90.65*pow(1e-18,1./2)*1e-3]         	;# [eV cm^(3/2)]	        
        variable C_p [expr 3.88*pow(1e-18,1./2)*1e-3]         	;# [eV cm^(3/2)]
        variable D_n 0.0            				;# [eV cm^(3/2)]				
    	variable D_p 0.0	    				;# [eV cm^(3/2)]
	
# Calculation of bandgap narrowing           
    	if { $::doping > 0.0 } {
	    variable deltaEg [expr {$A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)}]
    	} elseif { $::doping < 0.0 } {
	    variable deltaEg [expr {$A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)}]
	}
    }
    proc print {} {printPar::JainRoulstonSection}
}
GaAs::JainRoulston::init
