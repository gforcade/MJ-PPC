#----------------------------------------------------------------------#
# $Id: Blieske.tcl,v 1.6 2008/03/28 12:14:26 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: BGN model from Blieske
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing (BGN)
#! EXPRESSION: 
#! Bandgap narrowing  is calculated using 
#! deltaEg = A_i N^(1/3) + B_i N^(1/4) + C_i N^(1/2) + D_i N^(1/2)
#! where i is n for n-type or p for p-type
#! CALCULATED PARAMETER:
#! A_i, B_i, C_i, D_i
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! NOTES:
#! SDEVICE: EffectiveIntrinsicDensity(JainRoulston)
#! REFERENCE: 
#! U. Blieske, Konzentratorsolarzellen aus Galliumarsenid: Modul- und Tandem-Anwendung, Vol.
#! 333, VDI-Verlag GmbH, Düsseldorf, 1995

namespace eval GaAs::JainRoulston {
    proc init {} {
	variable A_n 7.5000e-09	;# [eV cm]
    	variable A_p 9.8000e-09	;# [eV cm]
	variable B_n 2.4000e-07	;# [eV cm^(3/4)]
    	variable B_p 3.9000e-07	;# [eV cm^(3/4)]
	variable C_n 9.1000e-12	;# [eV cm^(3/2)]
    	variable C_p 3.9000e-12	;# [eV cm^(3/2)]
    	variable D_n 0.0000e-00	;# [eV cm^(3/2)]
	variable D_p 0.0000e-00	;# [eV cm^(3/2)]
    	variable deltaEg
	
	if { $::doping > 0.0 } {
	    set deltaEg [expr {$A_n*pow($::doping,1.0/3.0) + $B_n*pow($::doping,1.0/4.0) + $C_n*pow($::doping,1.0/2.0) + $D_n*pow($::doping,1.0/2.0)}]
    	} elseif { $::doping < 0.0 } {
	    set deltaEg [expr $A_p*pow(abs($::doping),1.0/3.0) + $B_p*pow(abs($::doping),1.0/4.0) + $C_p*pow(abs($::doping),1.0/2.0) + $D_p*pow(abs($::doping),1.0/2.0)]
	}
    }
    proc print {} {printPar::JainRoulstonSection}
}
GaAs::JainRoulston::init
