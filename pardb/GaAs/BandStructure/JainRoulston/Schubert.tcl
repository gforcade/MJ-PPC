#----------------------------------------------------------------------#
# $Id: Schubert.tcl,v 1.6 2008/03/28 12:14:27 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Band gap Narrowing model from Schubert
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! <pre>
#! Bandgap narrowing  is calculated using 
#! </pre>
#! deltaEg = A_i*N^(1/3)  
#! <pre>
#! where i is n for n-type or p for p-type
#! </pre>
#! CALCULATED PARAMETER:
#! A_i
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! NOTES:
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! E.F.Schubert, Physical Foundations of Solid-State Devices, 2006

namespace eval GaAs::JainRoulston {
    proc init {} {
	variable A_n 6.6e-8	;# [eV cm]
    	variable A_p 2.4e-8	;# [eV cm]
	variable B_n 0.0	;# [eV cm^(3/4)]
    	variable B_p 0.0	;# [eV cm^(3/4)]
	variable C_n 0.0    	;# [eV cm^(3/2)]
    	variable C_p 0.0	;# [eV cm^(3/2)]
	variable D_n 0.0	;# [eV cm^(3/2)]
    	variable D_p 0.0	;# [eV cm^(3/2)]
	variable deltaEg
	
    	if { $::doping > 0.0 } {
	        set deltaEg [expr {$A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)}]
    	} elseif { $::doping < 0.0 } {
	    set deltaEg [expr {$A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)}]
	}
    }
    proc print {} {printPar::JainRoulstonSection}
}
GaAs::JainRoulston::init
