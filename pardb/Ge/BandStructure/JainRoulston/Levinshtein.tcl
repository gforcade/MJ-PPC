#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.2 2008/07/07 14:33:11 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: Ge
#! PROPERTY: Bandgap narrowing (BGN)
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i
#! VALIDITY: 
#! This model is valid for both n-Ge and p-Ge
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1996

namespace eval Ge::JainRoulston {
    proc init {} {
        variable A_n [expr 8.67*pow(1e-18,1./3)*1e-3]           ;# [eV cm]
        variable A_p [expr 8.21*pow(1e-18,1./3)*1e-3]           ;# [eV cm]
        variable B_n [expr 8.14*pow(1e-18,1./4)*1e-3]         	;# [eV cm^(3/4)]
        variable B_p [expr 9.18*pow(1e-18,1./4)*1e-3]         	;# [eV cm^(3/4)]
        variable C_n [expr 4.31*pow(1e-18,1./2)*1e-3]         	;# [eV cm^(3/2)]	        
        variable C_p [expr 5.77*pow(1e-18,1./2)*1e-3]         	;# [eV cm^(3/2)]
        variable D_n 0.0            				;# [eV cm^(3/2)]				
    	variable D_p 0.0	    				;# [eV cm^(3/2)]			
	variable deltaEg    	            
        
    	if { $::doping > 0.0 } {
	        set deltaEg [expr {$A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)}]
    	} elseif { $::doping < 0.0 } {
                set deltaEg [expr {$A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)}]
	}
    }
    proc print {} {printPar::JainRoulstonSection}
}
Ge::JainRoulston::init
