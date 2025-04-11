#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.3 2022/01/10 06:58:20 Gavin Forcade Exp $
#----------------------------------------------------------------------#
#! MODEL: Doping dependent model
#! MATERIAL: InP
#! PROPERTY: Bandgap narrowing (BGN)
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i, deltaEg
#! VALIDITY: 
#! This model is valid for both n-InP (Sieg) and p-InP (Levinshtein)
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! "Reabsorption, bandgap narrowing, and the reconciliation of photoluminescence 
#! spectra with electrical measurements for epitaxial n-InP", Sieg and Ringel, 1996.
#! HISTORY
#! Created on 2022/01/10 by Gavin Forcade

namespace eval InP::JainRoulston {
    proc init {} {
        variable A_n 7.14e-8            ;# [eV cm]
        variable A_p 10.3e-9            ;# [eV cm]
        variable B_n 0.0           ;# [eV cm^(3/4)]
        variable B_p 4.43e-7         	;# [eV cm^(3/4)]
        variable C_n 0.0         	;# [eV cm^(3/2)]	        
        variable C_p 3.38e-12         	;# [eV cm^(3/2)]
        variable D_n 0.0            	;# [eV cm^(3/2)]				
    	variable D_p 0.0	    	;# [eV cm^(3/2)]			 	            
        
    	if { $::doping > 0.0 } {
	    variable deltaEg [expr {$A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)}]
    	} elseif { $::doping < 0.0 } {
            variable deltaEg [expr {$A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)}]
	}
    }
    proc print {} {printPar::JainRoulstonSection}
}
InP::JainRoulston::init
